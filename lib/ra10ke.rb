require 'rake'
require 'rake/tasklib'

module Ra10ke
  class RakeTask < ::Rake::TaskLib
    def initialize(*args)
      namespace :r10k do
        desc "Print outdated forge modules"
        task :dependencies do
          require 'r10k/puppetfile'
          require 'puppet_forge'

          puppetfile = R10K::Puppetfile.new('.').load

          puppetfile.each do |puppet_module|
            if puppet_module.class == R10K::Module::Forge
              module_name = puppet_module.title.gsub('/', '-')
              forge_version = PuppetForge::Module.find(module_name).current_release.version
              installed_version = puppet_module.expected_version
              if installed_version != forge_version
                puts "#{puppet_module.title} is OUTDATED: #{installed_version} vs #{forge_version}"
              end
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
