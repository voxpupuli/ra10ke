source 'https://rubygems.org'

# Specify your gem's dependencies in ra10ke.gemspec
gemspec

group :release do
  gem 'faraday-retry', '~> 2.1', require: false
  gem 'github_changelog_generator', '~> 1.16.4', require: false
end

group :coverage, optional: ENV['COVERAGE'] != 'yes' do
  gem 'codecov', require: false
  gem 'simplecov-console', require: false
end

gem 'r10k', git: 'https://github.com/justinstoller/r10k', branch: 'support-more-minitar-versions'
