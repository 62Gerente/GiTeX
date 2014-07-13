# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gitex/version'

Gem::Specification.new do |spec|
  spec.name          = "gitex"
  spec.version       = GiTeX::VERSION
  spec.authors       = ["André Santos"]
  spec.email         = ["andreccdr@gmail.com"]
  spec.description   = %q{Latex command line tool with Git integration.}
  spec.summary       = %q{Latex command line tool with Git integration.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.executables   = ["gitex"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'thor', '~> 0.19'
  spec.add_dependency 'git'
end
