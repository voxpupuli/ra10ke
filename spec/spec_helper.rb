# frozen_string_literal: true
require 'simplecov'

module SimpleCov::Configuration
  def clean_filters
    @filters = []
  end
end

SimpleCov.configure do
  clean_filters
  load_profile 'test_frameworks'
end

SimpleCov.start do
  add_filter '/.rvm/'
  add_filter 'vendor'
  add_filter 'bundler'
end if ENV['COVERAGE']


def fixtures_dir
    File.join(__dir__, 'fixtures')
end
