#!/usr/bin/env rake

require "bundler/setup"
$:.unshift 'lib'
require 'travis/migrations'
require 'rails/generators/active_record/migration/migration_generator'

ActiveRecord::Base.schema_format = :sql

Rails.application.config.paths['db'] = 'db/main'
Rails.application.config.paths['db/migrate'] = 'db/main/migrate'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task :default => [:spec]

task :gen_migration, [:name] do |t, args|
  name = args.fetch(:name)
  ActiveRecord::Generators::MigrationGenerator.new([name]).create_migration_file
end
