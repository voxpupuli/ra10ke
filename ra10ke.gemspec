lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ra10ke/version'

Gem::Specification.new do |spec|
  spec.name          = "ra10ke"
  spec.version       = Ra10ke::VERSION
  spec.authors       = ["Theo Chatzimichos", "Vox Pupuli"]
  spec.email         = ["voxpupuli@groups.io"]
  spec.description   = %q{R10K and Puppetfile rake tasks}
  spec.summary       = %q{Syntax check for the Puppetfile, check for outdated installed puppet modules}
  spec.homepage      = "https://github.com/voxpupuli/ra10ke"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.4.0'

  spec.add_dependency "rake"
  spec.add_dependency "puppet_forge"
  spec.add_dependency "r10k"
  spec.add_dependency "git"
  spec.add_dependency "solve"
  spec.add_dependency 'semverse', '>= 2.0'
  spec.add_dependency 'table_print', '~> 1.5.6'
  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'simplecov'
end

