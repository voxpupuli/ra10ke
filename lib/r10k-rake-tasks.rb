require 'rake'
require 'rake/tasklib'

module R10KRakeTasks
  class RakeTask < ::Rake::TaskLib
    def initialize(*args)
      namespace :r10k do
        desc "Print outdated forge modules"
        task :dependencies do
          require 'r10k/puppetfile'


          puppetfile = R10K::Puppetfile.new('.').load

          puppetfile.each do |puppet_module|
            if puppet_module.class == R10K::Module::Forge
              module_name = puppet_module.title.gsub('/', '-')
              uri = URI("https://forgeapi.puppetlabs.com/v3/modules/#{module_name}")
              forge_version = JSON.parse(Net::HTTP.get(uri))['current_release']['version']
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

R10KRakeTasks::RakeTask.new
