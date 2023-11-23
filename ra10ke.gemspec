lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ra10ke/version'

Gem::Specification.new do |spec|
  spec.name          = 'ra10ke'
  spec.version       = Ra10ke::VERSION
  spec.authors       = ['Theo Chatzimichos', 'Vox Pupuli']
  spec.email         = ['voxpupuli@groups.io']
  spec.description   = 'R10K and Puppetfile rake tasks'
  spec.summary       = 'Syntax check for the Puppetfile, check for outdated installed puppet modules'
  spec.homepage      = 'https://github.com/voxpupuli/ra10ke'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'git', '~> 1.18'
  spec.add_dependency 'puppet_forge', '~> 5.0', '>= 5.0.1'
  spec.add_dependency 'r10k', '>= 2.6.5', '< 5'
  spec.add_dependency 'rake', '~> 13.0', '>= 13.0.6'
  spec.add_dependency 'semverse', '>= 2.0', '< 4'
  spec.add_dependency 'solve', '~> 4.0', '>= 4.0.4'
  spec.add_dependency 'table_print', '~> 1.5.6'
  spec.add_development_dependency 'pry', '~> 0.14.2'
  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'simplecov', '~> 0.22.0'
  spec.add_development_dependency 'voxpupuli-rubocop', '~> 2.1.0'
end
