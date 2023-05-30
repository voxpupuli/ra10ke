require 'rake'
require 'rake/tasklib'
require 'ra10ke/version'
require 'git'
require 'set'
require 'solve'
require 'yaml/store'
require 'semverse/version'
require 'fileutils'

# How many versions to fetch from the Forge, at most
FETCH_LIMIT = 3

module Ra10ke::Solve
  def define_task_solve_dependencies(*_args)
    desc 'Find missing or outdated module dependencies'
    task :solve_dependencies, [:allow_major_bump] do |_t, args|
      require 'r10k/puppetfile'
      require 'r10k/module/git'
      require 'r10k/module/metadata_file'
      require 'puppet_forge'

      allow_major_bump = false
      allow_major_bump = true if args[:allow_major_bump]

      # Same as in the dependencies task, but oh well.
      PuppetForge.user_agent = "ra10ke/#{Ra10ke::VERSION}"
      puppetfile = get_puppetfile
      puppetfile.load!
      PuppetForge.host = puppetfile.forge if /^http/.match?(puppetfile.forge)

      # ignore file allows for "don't tell me about this"
      ignore_modules = []
      ignore_modules = File.readlines('.r10kignore').each(&:chomp!) if File.exist?('.r10kignore')
      # Actual new logic begins here:
      cache = (ENV['XDG_CACHE_DIR'] || File.expand_path('~/.cache'))

      FileUtils.mkdir_p(cache)

      # Metadata cache, since the Forge is slow:
      @metadata_cache = YAML::Store.new File.join(cache, 'ra10ke.metadata_cache')
      # The graph of available module versions
      @graph = Solve::Graph.new
      # Set of modules that we have already added to the graph
      @processed_modules = Set.new
      # The set of "demands" we make of the solver. Will be a list of module names
      # Could also demand certain version constraints to hold, but the code does not do it
      # Can be either "module-name" or ["module-name", "version-constraint"]
      @demands = Set.new
      # List of modules we have in the Puppetfile, as [name, version] pairs
      @current_modules = []

      puppetfile.modules.each do |puppet_module|
        next if ignore_modules.include? puppet_module.title

        if puppet_module.instance_of?(R10K::Module::Forge)
          module_name = puppet_module.title.tr('/', '-')
          installed_version = puppet_module.expected_version
          puts "Processing Forge module #{module_name}-#{installed_version}"
          @current_modules << [module_name, installed_version]
          @graph.artifact(module_name, installed_version)
          constraint = '>=0.0.0'
          unless allow_major_bump
            ver = Semverse::Version.new installed_version
            if ver.major.zero?
              constraint = "~>#{installed_version}"
            else
              nver = Semverse::Version.new([ver.major + 1, 0, 0])
              constraint = "<#{nver}"
            end
          end
          puts "...Adding a demand: #{module_name} #{constraint}"

          @demands.add([module_name, constraint])
          puts '...Fetching latest release version information'
          forge_rel = PuppetForge::Module.find(module_name).current_release
          mod = @graph.artifact(module_name, forge_rel.version)
          puts '...Adding its requirements to the graph'
          meta = get_release_metadata(module_name, forge_rel)
          add_reqs_to_graph(mod, meta)
        end

        next unless puppet_module.instance_of?(R10K::Module::Git)

        # This downloads the git module to modules/modulename
        meta = fetch_git_metadata(puppet_module)
        version = get_key_or_sym(meta, :version)
        module_name = puppet_module.title.tr('/', '-')
        @current_modules << [module_name, version]
        # We should add git modules with exact versions, or the system might recommend updating to a
        # Forge version.
        puts "Adding git module #{module_name} to the list of required modules with exact version: #{version}"
        @demands.add([module_name, version])
        mod = @graph.artifact(module_name, version)
        puts "...Adding requirements for git module #{module_name}-#{version}"
        add_reqs_to_graph(mod, meta)
      end
      puts
      puts 'Resolving dependencies...'
      puts 'WARNING:  Potentially breaking updates are allowed for this resolution' if allow_major_bump
      result = Solve.it!(@graph, @demands, sorted: true)
      puts
      print_module_diff(@current_modules, result)
    end
  end

  private

  def get_release_metadata(name, release)
    meta = nil
    @metadata_cache.transaction do
      meta = @metadata_cache["#{name}-#{release.version}"]
      unless meta
        meta = release.metadata
        @metadata_cache["#{name}-#{release.version}"] = meta
      end
    end
    meta
  end

  def fetch_git_metadata(puppet_module)
    # No caching here. I don't think it's really possible to do in a sane way.
    puts "Fetching git module #{puppet_module.title}, saving to modules/"
    puppet_module.sync
    metadata_path = Pathname.new(puppet_module.full_path) + 'metadata.json'
    unless metadata_path.exist?
      puts 'WARNING: metadata.json does not exist, assuming version 0.0.0 and no dependencies'
      return {
        version: '0.0.0',
        name: puppet_module.title,
        dependencies: [],
      }
    end
    metadata = R10K::Module::MetadataFile.new(metadata_path)
    metadata = metadata.read
    {
      version: metadata.version,
      name: metadata.name,
      dependencies: metadata.dependencies,
    }
  end

  # Is there a better way? :(
  def get_key_or_sym(hash, k)
    hash.fetch(k.to_sym, hash.fetch(k.to_s, nil))
  end

  # At least puppet-extlib has malformed metadata
  def get_version_req(dep)
    req = get_key_or_sym(dep, :version_requirement)
    req ||= get_key_or_sym(dep, :version_range)
    req
  end

  def print_module_diff(current, resolution)
    current.sort!
    resolution.sort!
    outdated = []
    missing = []
    resolution.each do |mod|
      cur_mod, cur_version = current.shift
      mod, version = mod
      if (cur_mod == mod) && cur_version && (cur_version != version)
        outdated << [mod, cur_version, version]
      elsif cur_mod != mod
        missing << [mod, version]
        current.unshift [cur_mod, cur_version]
      end
    end
    missing.each do |m|
      puts format('MISSING:  %-25s %s', *m)
    end
    outdated.each do |o|
      puts format('OUTDATED: %-25s %s -> %s', *o)
    end
  end

  def add_reqs_to_graph(artifact, metadata, no_demands = nil)
    deps = get_key_or_sym(metadata, :dependencies)
    my_name = get_key_or_sym(metadata, :name)
    deps.each do |dep|
      name = get_key_or_sym(dep, :name).tr('/', '-')
      # Add dependency to the global set of modules we want, so that we can
      # actually ask the solver for the versioned thing
      @demands.add(name) unless no_demands
      ver = get_version_req(dep)
      ver ||= '>=0.0.0'
      ver.split(/(?=<)/).each do |bound|
        bound.strip!
        v = begin
          Semverse::Constraint.new(bound)
        rescue StandardError
          nil
        end
        if v
          artifact.depends(name, v.to_s)
        else
          puts "WARNING: Invalid version constraint: #{bound}"
        end
      end
      # Find the dependency in the forge, unless it's already been processed
      # and add its releases to the global graph
      next unless @processed_modules.add?(name)

      puts "Fetching module info for #{name}"
      mod = begin
        PuppetForge::Module.find(name)
      rescue StandardError
        # It's probably a git module
        nil
      end
      next unless mod # Git module, or non-forge dependency. Skip to next for now.

      # Fetching metadata for all releases takes ages (which is weird, since it's mostly static info)
      mod.releases.take(FETCH_LIMIT).each do |rel|
        meta = get_release_metadata(name, rel)
        rel_artifact = @graph.artifact(name, rel.version)
        puts "...Recursively adding requirements for dependency #{name} version #{rel.version}"
        # We don't want to add the requirements to the list of demands for all versions,
        # but we need them in the graph to be able to solve dependencies
        add_reqs_to_graph(rel_artifact, meta, :no_demands)
      end
    end
  end
end
