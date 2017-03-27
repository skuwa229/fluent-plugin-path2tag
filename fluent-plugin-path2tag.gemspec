# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent/plugin/path2tag/version'

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-path2tag"
  spec.version       = Fluent::Plugin::Path2tag::VERSION
  spec.authors       = ["Shota Kuwahara"]
  spec.email         = ["shota.kuwahara@skuwa229.com"]

  spec.summary       = %q{Fluentd Output filter plugin.}
  spec.homepage      = "https://github.com/skuwa229/fluent-plugin-path2tag"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "test-unit", ">= 3.1.0"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "fluentd", [">= 0.10.0", "< 0.14.0"]
end
