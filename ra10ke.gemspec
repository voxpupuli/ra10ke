lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ra10ke/version'

Gem::Specification.new do |spec|
  spec.name          = "ra10ke"
  spec.version       = Ra10ke::VERSION
  spec.authors       = ["Theo Chatzimichos"]
  spec.email         = ["tampakrap@gmail.com"]
  spec.description   = %q{R10K and Puppetfile rake tasks}
  spec.summary       = %q{Syntax check for the Puppetfile, check for outdated installed puppet modules}
  spec.homepage      = "https://github.com/tampakrap/ra10ke"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rake"
  spec.add_dependency "puppet_forge"
  spec.add_dependency "r10k"
end
