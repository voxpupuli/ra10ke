source 'https://rubygems.org'

# Specify your gem's dependencies in ra10ke.gemspec
gemspec

group :release do
  gem 'github_changelog_generator', require: false
end

group :coverage, optional: ENV['COVERAGE'] != 'yes' do
  gem 'codecov', require: false
  gem 'simplecov-console', require: false
end
