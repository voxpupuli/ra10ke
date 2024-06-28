require 'rake'
require 'rake/clean'
require 'rubygems'
require 'bundler/gem_tasks'
require 'fileutils'
require 'rspec/core'
require 'rspec/core/rake_task'

CLEAN.include('pkg/', 'tmp/')
CLOBBER.include('Gemfile.lock')

task default: [:spec]

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

begin
  require 'github_changelog_generator/task'
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    version = Ra10ke::VERSION
    config.future_release = "v#{version}" if /^\d+\.\d+.\d+$/.match?(version)
    config.header = "# Changelog\n\nAll notable changes to this project will be documented in this file."
    config.exclude_labels = %w[duplicate question invalid wontfix wont-fix skip-changelog github_actions]
    config.user = 'voxpupuli'
    config.project = 'ra10ke'
  end
rescue LoadError
end

begin
  require 'voxpupuli/rubocop/rake'
rescue LoadError
  # the voxpupuli-rubocop gem is optional
end
