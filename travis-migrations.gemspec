# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'travis_migrations/version'

Gem::Specification.new do |s|
  s.name         = "travis-migrations"
  s.version      = TravisMigrations::VERSION
  s.authors      = ["Travis CI"]
  s.email        = "contact@travis-ci.org"
  s.summary   = %q{Gem for migrations on Travis CI.}
  s.homepage     = "https://github.com/travis-ci/travis-migrations"
  s.summary      = "The Migrations of Travis"

  s.files        = `git ls-files`.split($/)

  s.require_paths = ["lib"]
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'

  s.add_dependency 'bundler'
  s.add_dependency 'rake'
  s.add_dependency 'activerecord',      '~> 3.2.19'
  s.add_dependency 'rails',             '~> 3.2.12'
  s.add_dependency 'rails_12factor'

  # # travis
  # s.add_dependency 'travis-config',     '~> 0.1.0'

  # db
  s.add_dependency 'data_migrations',   '~> 0.0.1'
  s.add_dependency 'pg'
  s.add_dependency 'micro_migrations'

  # Disallow pushing to rubygems
  s.metadata['allowed_push_host'] = 'https://nonexistent-host.example.com' if s.respond_to?(:metadata)

end
