require 'rake'
require 'rake/tasklib'
require 'ra10ke/version'
require 'ra10ke/solve'
require 'ra10ke/syntax'
require 'ra10ke/resolver'
require 'ra10ke/dependencies'
require 'ra10ke/deprecation'
require 'ra10ke/duplicates'
require 'ra10ke/install'
require 'ra10ke/validate'
require 'git'
require 'semverse'
require 'r10k/puppetfile'
module Ra10ke
  class RakeTask < ::Rake::TaskLib
    include Ra10ke::Solve
    include Ra10ke::Syntax
    include Ra10ke::Dependencies
    include Ra10ke::Deprecation
    include Ra10ke::Duplicates
    include Ra10ke::Install
    include Ra10ke::Validate
    include Ra10ke::Resolver

    attr_accessor :basedir, :moduledir, :puppetfile_path, :puppetfile_name, :force, :purge

    def initialize(*args)
      @basedir         = Dir.pwd
      @moduledir       = nil
      @puppetfile_path = nil
      @puppetfile_name = nil
      @force           = nil
      @purge           = false

      yield(self) if block_given?

      namespace :r10k do
        define_task_solve_dependencies(*args)
        define_task_syntax(*args)
        define_task_dependencies(*args)
        define_task_deprecation(*args)
        define_task_duplicates(*args)
        define_task_install(*args)
        define_task_validate(*args)
        define_task_print_git_conversion(*args)
        define_task_resolver(*args)
      end
    end

    def get_puppetfile
      R10K::Puppetfile.new(@basedir, @moduledir, @puppetfile_path, @puppetfile_name, @force)
    rescue ArgumentError # R10k < 2.6.0
      R10K::Puppetfile.new(@basedir, @moduledir,
                           @puppetfile_path || File.join(@basedir, @puppetfile_name || 'Puppetfile'))
    end
  end
end
