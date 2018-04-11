#!/usr/bin/env rake

require "bundler/setup"
$:.unshift 'lib'
require 'travis/migrations'

ActiveRecord::Base.schema_format = :sql

Rails.application.config.paths['db'] = 'db/main'
Rails.application.config.paths['db/migrate'] = 'db/main/migrate'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task :default => [:spec]

if Rails.env.production?
  puts "Running in production environment, disabling db:structure:dump task"
  Rake::Task["db:structure:dump"].clear
end
