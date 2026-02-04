# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "iml/version"
require "yaml"

Gem::Specification.new do |spec|
  gemspec = YAML.safe_load_file("gemspec.yml")
  spec.name = "iml"
  spec.version = IML::VERSION
  spec.authors = ["Adam Ladachowski"]
  spec.email = ["adam.ladachowski@gmail.com"]

  spec.summary = "Media string and object manipulation library"
  spec.description = "Library which parses strings into media objects"
  spec.homepage = "https://github.com/aladac/iml"
  spec.license = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["yard.run"] = "yri"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1"

  gemspec["dependencies"].each do |name, version|
    spec.add_dependency(name, version)
  end

  gemspec["development_dependencies"].each do |name, version|
    spec.add_development_dependency(name, version)
  end
end
