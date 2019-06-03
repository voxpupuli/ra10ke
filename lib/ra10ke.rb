require 'rake'
require 'rake/tasklib'
require 'ra10ke/version'
require 'ra10ke/solve'
require 'ra10ke/syntax'
require 'ra10ke/dependencies'
require 'ra10ke/install'
require 'git'
require 'semverse'

module Ra10ke
  class RakeTask < ::Rake::TaskLib
    include Ra10ke::Solve
    include Ra10ke::Syntax
    include Ra10ke::Dependencies
    include Ra10ke::Install

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
        define_task_install(*args)
      end
    end

    def get_puppetfile
      R10K::Puppetfile.new(@basedir, @moduledir, @puppetfile_path, @puppetfile_name, @force)
    end
  end
end
