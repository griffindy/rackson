# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rackson/version'

Gem::Specification.new do |spec|
  spec.name          = "rackson"
  spec.version       = Rackson::VERSION
  spec.authors       = ["Dylan Griffin"]
  spec.email         = ["dgriffin@twitter.com"]
  spec.summary       = %q{A library to turn JSON into POROs.}
  spec.description   = %q{A library to turn JSON into POROs in a somewhat typesafe manner.}
  spec.homepage      = "https://github.com/griffindy/rackson"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10.1"
end
