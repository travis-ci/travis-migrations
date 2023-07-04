#!/usr/bin/env rake

require 'rake/notes/rake_task'
require 'routes'
require 'bundler/setup'
$:.unshift 'lib'
require 'travis/migrations'
require 'rails/generators/active_record/migration/migration_generator'

ActiveRecord.schema_format = :sql

Rails.application.config.paths['db'] = 'db/main'
Rails.application.config.paths['db/migrate'] = 'db/main/migrate'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task default: [:spec]

if Rails.env.production?
  puts 'Running in production environment, disabling db:structure:dump task'
  Rake::Task['db:structure:dump'].clear
end

namespace :db do
  namespace :structure do
    task :dump do
      version = ActiveRecord::Base.connection.execute("SELECT current_setting('server_version')")[0]['current_setting']
      if version.split('.').first.to_i > 9
        puts <<~MESSAGE
          \033[0;31mYou're running PostgreSQL #{version}. We're running PostgreSQL 9.x
          on production and PostgreSQL dumps from higher versions are incompatible,
          please don't commit the structure.sql file\033[0m
        MESSAGE
      end
    end
  end
end

task :gen_migration, [:name] do |_t, args|
  name = args.fetch(:name)
  ActiveRecord::Generators::MigrationGenerator.new([name]).create_migration_file
end
