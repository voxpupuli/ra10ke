require 'rake'
require 'rake/clean'
require 'rubygems'
require 'bundler/gem_tasks'
require 'fileutils'

CLEAN.include("pkg/", "tmp/")
CLOBBER.include("Gemfile.lock")

task :default => [:clean, :build]
