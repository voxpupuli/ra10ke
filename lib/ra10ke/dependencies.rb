require 'semverse'
require 'r10k/puppetfile'
require 'puppet_forge'
require 'table_print'
require 'git'

module Ra10ke::Dependencies
  class Verification

    def self.version_formats
      @version_formats ||= {}
    end

    # Registers a block that finds the latest version.
    # The block will be called with a list of tags.
    # If the block returns nil the next format will be tried.
    def self.register_version_format(name, &block)
      version_formats[name] = block
    end

    Ra10ke::Dependencies::Verification.register_version_format(:semver) do |tags|
      latest_tag = tags.map do |tag|
        begin
          Semverse::Version.new tag[/\Av?(.*)\Z/, 1]
        rescue Semverse::InvalidVersionFormat
          # ignore tags that do not comply to semver
          nil
        end
      end.select { |tag| !tag.nil? }.sort.last.to_s.downcase
      latest_ref = tags.detect { |tag| tag[/\Av?(.*)\Z/, 1] == latest_tag }
    end
    attr_reader :puppetfile

    def initialize(pfile)
      @puppetfile = pfile
       # semver is the default version format.
  
      puppetfile.load!
    end

    def get_latest_ref(remote_refs)
      tags = remote_refs['tags'].keys
      latest_ref = nil
      self.class.version_formats.detect { |_, block| latest_ref = block.call(tags) }
      latest_ref = 'undef (tags do not follow any known pattern)' if latest_ref.nil?
      latest_ref
    end

    def ignored_modules
      # ignore file allows for "don't tell me about this"
      @ignored_modules ||= begin
        File.readlines('.r10kignore').each {|l| l.chomp!} if File.exist?('.r10kignore')
      end || []
    end
  
    # @summary creates an array of module hashes with version info 
    # @param {Object} supplied_puppetfile - the parsed puppetfile object 
    # @returns {Array} array of version info for each module
    # @note does not include ignored modules or modules up2date
    def processed_modules(supplied_puppetfile = puppetfile)

      supplied_puppetfile.modules.map do |puppet_module|
        next if ignored_modules.include? puppet_module.title
        if puppet_module.class == ::R10K::Module::Forge
          module_name = puppet_module.title.gsub('/', '-')
          forge_version = ::PuppetForge::Module.find(module_name).current_release.version
          installed_version = puppet_module.expected_version
          {
            name: puppet_module.title,
            installed: installed_version,
            latest: forge_version,
            type: 'forge',
            message: installed_version != forge_version ? :outdated : :current
          }
        
        elsif puppet_module.class == R10K::Module::Git
          # use helper; avoid `desired_ref`
          # we do not want to deal with `:control_branch`
          ref = puppet_module.version
          next unless ref

          remote = puppet_module.instance_variable_get(:@remote)
          remote_refs = Git.ls_remote(remote)

          # skip if ref is a branch
          next if remote_refs['branches'].key?(ref)

          if remote_refs['tags'].key?(ref)
            # there are too many possible versioning conventions
            # we have to be be opinionated here
            # so semantic versioning (vX.Y.Z) it is for us
            # as well as support for skipping the leading v letter
            #
            # register own version formats with
            # Ra10ke::Dependencies.register_version_format(:name, &block)
            latest_ref = get_latest_ref(remote_refs)
          elsif ref.match(/^[a-z0-9]{40}$/)
            ref = ref.slice(0,8)
            # for sha just assume head should be tracked
            latest_ref = remote_refs['head'][:sha].slice(0,8)
          else
            raise "Unable to determine ref type for #{puppet_module.title}"
          end
          {
            name: puppet_module.title,
            installed: ref,
            latest: latest_ref,
            type: 'git',
            message: ref != latest_ref ? :outdated : :current
          }

        end
      end.compact
    end

    def outdated(supplied_puppetfile = puppetfile)
      processed_modules.find_all do | mod |
        mod[:message] == :outdated
      end
    end

    def print_table(mods)
      puts
      tp mods, { name: { width: 50 } }, :installed, :latest, :type, :message
    end
  end

  def define_task_dependencies(*_args)
    desc "Print outdated forge modules"
    task :dependencies do
      PuppetForge.user_agent = "ra10ke/#{Ra10ke::VERSION}"
      puppetfile = get_puppetfile
      PuppetForge.host = puppetfile.forge if puppetfile.forge =~ /^http/
      dependencies = Ra10ke::Dependencies::Verification.new(puppetfile)
      dependencies.print_table(dependencies.outdated)
    end
  end
end
