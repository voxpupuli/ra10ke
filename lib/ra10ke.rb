require 'rake'
require 'rake/tasklib'
require 'ra10ke/version'
require 'ra10ke/solve'
require 'ra10ke/syntax'
require 'ra10ke/dependencies'
require 'git'
require 'semverse'

module Ra10ke
  class RakeTask < ::Rake::TaskLib
    include Ra10ke::Solve
    include Ra10ke::Syntax
    include Ra10ke::Dependencies

    attr_accessor :basedir, :moduledir, :puppetfile_path, :puppetfile_name, :force

    def initialize(*args)
      @basedir         = Dir.pwd
      @moduledir       = nil
      @puppetfile_path = nil
      @puppetfile_name = nil
      @force           = nil

      yield(self) if block_given?

      namespace :r10k do
        define_task_solve_dependencies(*args)
        define_task_syntax(*args)
        define_task_dependencies(*args)

        desc "Install modules specified in Puppetfile"
        task :install do
          require 'r10k/puppetfile'

          puppetfile = get_puppetfile
          puppetfile.load!

          puts "Processing Puppetfile for fixtures"
          puppetfile.modules.each do |mod|
            if mod.status == :insync
              puts "Skipping #{mod.name} (#{mod.version}) already in sync"
            else
              if mod.status == :absent
                msg = "installed #{mod.name}"
              else
                msg = "updated #{mod.name} from #{mod.version} to"
              end
              mod.sync
              if mod.status != :insync
                puts "Failed to sync #{mod.name}".red
              else
                puts "Successfully #{msg} #{mod.version}".green
              end
            end
          end
        end

      end
    end

    def get_puppetfile
      R10K::Puppetfile.new(@basedir, @moduledir, @puppetfile_path, @puppetfile_name, @force)
    end
  end
end
