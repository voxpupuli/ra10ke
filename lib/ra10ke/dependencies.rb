require 'semverse'
require 'r10k/puppetfile'
require 'puppet_forge'
require 'table_print'
require 'git'

module Ra10ke::Dependencies
  GOOD_EMOJI = ENV['GOOD_EMOJI'] || '👍'
  BAD_EMOJI = ENV['BAD_EMOJI'] || '😨'

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
        Semverse::Version.new tag[/\Av?(.*)\Z/, 1]
      rescue Semverse::InvalidVersionFormat
        # ignore tags that do not comply to semver
        nil
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
        File.readlines('.r10kignore').each { |l| l.chomp! } if File.exist?('.r10kignore')
      end || []
    end

    # @summary creates an array of module hashes with version info
    # @param {Object} supplied_puppetfile - the parsed puppetfile object
    # @returns {Array} array of version info for each module
    # @note does not include ignored modules or modules up2date
    def processed_modules(supplied_puppetfile = puppetfile)
      threads = []
      supplied_puppetfile.modules.each do |puppet_module|
        next if ignored_modules.include? puppet_module.title
        # Ignore modules where ref is explicitly set to control branch
        next if puppet_module.instance_of?(R10K::Module::Git) && puppet_module.desired_ref == :control_branch

        threads << Thread.new do
          if puppet_module.instance_of?(::R10K::Module::Forge)
            module_name = puppet_module.title.tr('/', '-')
            forge_version = ::PuppetForge::Module.find(module_name).current_release.version
            installed_version = puppet_module.expected_version
            {
              name: puppet_module.title,
              installed: installed_version,
              latest: forge_version,
              type: 'forge',
              message: (installed_version == forge_version) ? :current : :outdated,
            }

          elsif puppet_module.instance_of?(R10K::Module::Git)
            # use helper; let r10k figure out correct ref
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
            elsif /^[a-z0-9]{40}$/.match?(ref)
              ref = ref.slice(0, 8)
              # for sha just assume head should be tracked
              latest_ref = remote_refs['head'][:sha].slice(0, 8)
            else
              raise "Unable to determine ref type for #{puppet_module.title}"
            end
            {
              name: puppet_module.title,
              installed: ref,
              latest: latest_ref,
              type: 'git',
              message: (ref == latest_ref) ? :current : :outdated,
            }

          end
        rescue R10K::Util::Subprocess::SubprocessError => e
          {
            name: puppet_module.title,
            installed: nil,
            latest: nil,
            type: :error,
            message: e.message,
          }
        end
      end
      threads.map { |th| th.join.value }.compact
    end

    def outdated(_supplied_puppetfile = puppetfile)
      processed_modules.find_all do |mod|
        mod[:message] == :outdated
      end
    end

    def print_table(mods)
      puts
      tp mods, { name: { width: 50 } }, :installed, :latest, :type, :message
    end
  end

  def define_task_print_git_conversion(*_args)
    desc 'Convert and print forge modules to git format'
    task :print_git_conversion do
      require 'ra10ke/git_repo'
      require 'r10k/puppetfile'
      require 'puppet_forge'

      PuppetForge.user_agent = "ra10ke/#{Ra10ke::VERSION}"
      puppetfile = get_puppetfile
      puppetfile.load!
      PuppetForge.host = puppetfile.forge if puppetfile.forge =~ /^http/

      # ignore file allows for "don't tell me about this"
      ignore_modules = []
      ignore_modules = File.readlines('.r10kignore').each { |l| l.chomp! } if File.exist?('.r10kignore')
      forge_mods = puppetfile.modules.find_all do |mod|
        mod.instance_of?(R10K::Module::Forge) && mod.v3_module.homepage_url?
      end

      threads = forge_mods.map do |mod|
        Thread.new do
          source_url = mod.v3_module.attributes.dig(:current_release, :metadata, :source) || mod.v3_module.homepage_url
          # git:// does not work with ls-remote command, convert to https
          source_url = source_url.gsub('git://', 'https://')
          source_url = source_url.gsub(/\Agit@(.*):(.*)/) do
            "https://#{::Regexp.last_match(1)}/#{::Regexp.last_match(2)}"
          end
          repo = ::Ra10ke::GitRepo.new(source_url)
          ref = repo.get_ref_like(mod.expected_version)
          ref_name = ref ? ref[:name] : "bad url or tag #{mod.expected_version} is missing"
          <<~EOF
            mod '#{mod.name}',
              :git => '#{source_url}',
              :ref => '#{ref_name}'

          EOF
        end
      end
      output = threads.map { |th| th.join.value }
      puts output
    end
  end

  def define_task_dependencies(*_args)
    desc 'Print outdated forge modules'
    task :dependencies do
      PuppetForge.user_agent = "ra10ke/#{Ra10ke::VERSION}"
      puppetfile = get_puppetfile
      if puppetfile.respond_to? :environment=
        # Use a fake environment object to reduce log spam and keep :control_branch reference for R10k >= 3.10.0
        fake_env = Object.new
        fake_env.instance_eval do
          def module_conflicts?(*)
            false
          end

          def name
            'test'
          end

          def ref
            :control_branch
          end
        end
        puppetfile.environment = fake_env
      end
      PuppetForge.host = puppetfile.forge if /^http/.match?(puppetfile.forge)
      dependencies = Ra10ke::Dependencies::Verification.new(puppetfile)
      dependencies.print_table(dependencies.outdated)

      if dependencies.outdated.any?
        abort(BAD_EMOJI + '  Not all modules in the Puppetfile are up2date. '.red + BAD_EMOJI)
      else
        puts(GOOD_EMOJI + '  All modules in the Puppetfile are up2date. '.green + GOOD_EMOJI)
      end
    end
  end
end
