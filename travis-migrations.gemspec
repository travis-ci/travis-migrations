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

  spec.add_runtime_dependency 'activerecord', '~> 4.2'
  spec.add_runtime_dependency 'pg', '~> 0.18'
  spec.add_runtime_dependency 'rake', '~> 10.4'

  spec.add_runtime_dependency 'micro_migrations', '~> 0.0'
  spec.add_runtime_dependency 'data_migrations', '~> 0.0'

  spec.add_development_dependency 'bundler', '~> 1.7'


  # Disallow pushing to rubygems
  spec.metadata['allowed_push_host'] = 'https://nonexistent-host.example.com' if spec.respond_to?(:metadata)
end
