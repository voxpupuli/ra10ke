require 'rake'
require 'rake/clean'
require 'rubygems'
require 'bundler/gem_tasks'
require 'fileutils'
require 'rspec/core'
require 'rspec/core/rake_task'

CLEAN.include("pkg/", "tmp/")
CLOBBER.include("Gemfile.lock")

task :default => [:spec]

RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
end
