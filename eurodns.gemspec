# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eurodns/version'

Gem::Specification.new do |spec|
  spec.name          = "eurodns"
  spec.version       = EuroDNS::VERSION
  spec.authors       = ["Fernando Morgenstern"]
  spec.email         = ["contato@fernandomarcelo.com"]
  spec.description   = "A Ruby wrapper for EuroDNS API."
  spec.summary       = "A Ruby wrapper for EuroDNS API."
  spec.homepage      = "https://github.com/fernandomm/eurodns"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "guard-test"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "debugger-pry"
  spec.add_dependency("httparty")
  spec.add_dependency("nokogiri")
end
