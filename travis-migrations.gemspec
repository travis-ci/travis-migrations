# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'travis/migrations/version'

Gem::Specification.new do |spec|
  spec.name          = 'travis-migrations'
  spec.version       = Travis::Migrations::VERSION
  spec.license       = 'MIT'
  spec.authors       = ['Carla Drago']
  spec.email         = ['contact+travis-migrations-gem@travis-ci.org']
  spec.summary       = %q{Gem for Travis migrations.}
  spec.description   = %q{This gem enables the easy integration of travis org migrations with other applications.}
  spec.homepage      = "https://github.com/travis-ci/travis-migrations"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # Disallow pushing to rubygems
  spec.metadata['allowed_push_host'] = 'https://nonexistent-host.example.com' if spec.respond_to?(:metadata)


  spec.add_development_dependency 'rails', '~> 5.2'
  spec.add_development_dependency 'pg', '~> 1.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
end
