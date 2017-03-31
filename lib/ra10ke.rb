require 'rake'
require 'rake/tasklib'
require 'ra10ke/version'
require 'ra10ke/solve'
require 'git'

module Ra10ke
  class RakeTask < ::Rake::TaskLib
    def initialize(*args)
      namespace :r10k do
        desc "Print outdated forge modules"
        task :dependencies do
          require 'r10k/puppetfile'
          require 'puppet_forge'

          PuppetForge.user_agent = "ra10ke/#{Ra10ke::VERSION}"
          puppetfile = R10K::Puppetfile.new('.')
          puppetfile.load!

          # ignore file allows for "don't tell me about this"
          ignore_modules = []
          if File.exist?('.r10kignore')
            ignore_modules = File.readlines('.r10kignore').each {|l| l.chomp!}
          end

          puppetfile.modules.each do |puppet_module|
            next if ignore_modules.include? puppet_module.title
            if puppet_module.class == R10K::Module::Forge
              module_name = puppet_module.title.gsub('/', '-')
              forge_version = PuppetForge::Module.find(module_name).current_release.version
              installed_version = puppet_module.expected_version
              if installed_version != forge_version
                puts "#{puppet_module.title} is OUTDATED: #{installed_version} vs #{forge_version}"
              end
            end

            if puppet_module.class == R10K::Module::Git
              remote = puppet_module.instance_variable_get(:@remote)
              ref    = puppet_module.instance_variable_get(:@desired_ref)

              # some guards to prevent unnessicary execution
              next unless ref
              next if ref == 'master'

              remote_refs = Git.ls_remote(remote)

              # skip if ref is a branch
              next if remote_refs['branches'].key?(ref)

              ref_type = 'sha'    if ref.match(/^[a-z0-9]{40}$/)
              ref_type = 'tag'    if remote_refs['tags'].key?(ref)
              case ref_type
              when 'sha'
                latest_ref = remote_refs['head'][:sha]
              when 'tag'
                # we have to be opinionated here, due to multiple conventions only one can reign suppreme
                # as such tag v#.#.# is what will pick.
                if ref.match(/^[vV]\d/)
                  tags = remote_refs['tags']
                  version_tags = tags.select { |f| /^[vV]\d/.match(f) }
                  latest_ref = version_tags.keys.sort.last
                end
              else
                raise "Unable to determine ref_type for #{puppet_module.title}"
              end

              puts "#{puppet_module.title} is OUTDATED: #{ref} vs #{latest_ref}" if ref != latest_ref
            end
          end
        end

        desc "Syntax check Puppetfile"
        task :syntax do
          require 'r10k/action/puppetfile/check'

          puppetfile = R10K::Action::Puppetfile::Check.new({
            :root => ".",
            :moduledir => nil,
            :puppetfile => nil
          }, '')
          puppetfile.call
        end
      end
    end
  end
end

Ra10ke::RakeTask.new
