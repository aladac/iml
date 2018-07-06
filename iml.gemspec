# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iml/version'
require 'yaml'

Gem::Specification.new do |spec|
  gemspec = YAML.load_file('gemspec.yml')
  spec.name          = 'iml'
  spec.version       = IML::VERSION
  spec.authors       = ['Adam Ladachowski']
  spec.email         = ['adam.ladachowski@gmail.com']

  spec.summary       = 'Media string and object manipulation library'
  spec.description   = 'Library which parses strings into media objects'
  spec.homepage      = 'https://github.com/aladac/iml'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'

  gemspec['dependencies'].each do |name, version|
    spec.add_dependency(name, version)
  end

  gemspec['development_dependencies'].each do |name, version|
    spec.add_development_dependency(name, version)
  end
end
