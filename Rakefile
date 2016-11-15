#!/usr/bin/env rake

require "bundler/setup"
require "micro_migrations"

require 'sequel'

ActiveRecord::Base.schema_format = :sql

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task :default => [:spec]

Rake::Task["db:structure:dump"].clear unless Rails.env.development?

def connect_sequel
  if ENV['LOGS_DATABASE_URL'].nil?
    raise 'No logs database URL set, you must set LOGS_DATABASE_URL env var'
  end

  Sequel.connect(ENV['LOGS_DATABASE_URL']).tap do |db|
    db.timezone = :utc
  end
end

namespace 'logs:db' do
  desc 'Apply migrations'
  task :migrate, [:version] do |_t, args|
    Sequel.extension(:migration)
    db = connect_sequel

    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, 'db/migrate_logs', target: args[:version].to_i)
    else
      puts 'Migrating to latest'
      Sequel::Migrator.run(db, 'db/migrate_logs')
    end
  end

  desc 'List status for migrations'
  task :status do
    Sequel.extension(:migration)
    db = connect_sequel

    applied = Sequel::TimestampMigrator.new(db, 'db/migrations').applied_migrations
    all_migrations = Dir['db/migrations/*.rb'].map { |file| File.basename(file) }.sort
    all_migrations.each do |migration_file|
      if applied.include?(migration_file)
        puts "   up   #{migration_file}"
      else
        puts "  down  #{migration_file}"
      end
    end
  end
end

module ActiveRecord
  class Migration
    class << self
      attr_accessor :disable_ddl_transaction
    end

    # Disable DDL transactions for this migration
    def self.disable_ddl_transaction!
      @disable_ddl_transaction = true
    end

    def disable_ddl_transaction # :nodoc:
      self.class.disable_ddl_transaction
    end
  end

  class Migrator
    def use_transaction?(migration)
      !migration.disable_ddl_transaction && Base.connection.supports_ddl_transactions?
    end

    def ddl_transaction(migration, &block)
      if use_transaction?(migration)
        Base.transaction { block.call }
      else
        block.call
      end
    end

    def migrate(&block)
      puts "Custom migrate in Rakefile is being called."
      current = migrations.detect { |m| m.version == current_version }
      target = migrations.detect { |m| m.version == @target_version }

      if target.nil? && @target_version && @target_version > 0
        raise UnknownMigrationVersionError.new(@target_version)
      end

      start = up? ? 0 : (migrations.index(current) || 0)
      finish = migrations.index(target) || migrations.size - 1
      runnable = migrations[start..finish]

      # skip the last migration if we're headed down, but not ALL the way down
      runnable.pop if down? && target

      ran = []
      runnable.each do |migration|
        if block && !block.call(migration)
          next
        end

        Base.logger.info "Migrating to #{migration.name} (#{migration.version})" if Base.logger

        seen = migrated.include?(migration.version.to_i)

        # On our way up, we skip migrating the ones we've already migrated
        next if up? && seen

        # On our way down, we skip reverting the ones we've never migrated
        if down? && !seen
          migration.announce 'never migrated, skipping'; migration.write
          next
        end

        begin
          ddl_transaction(migration) do
            migration.migrate(@direction)
            record_version_state_after_migrating(migration.version)
          end
          ran << migration
        rescue => e
          canceled_msg = Base.connection.supports_ddl_transactions? ? "this and " : ""
          raise StandardError, "An error has occurred, #{canceled_msg}all later migrations canceled:\n\n#{e}", e.backtrace
        end
      end
      ran
    end
  end

  class MigrationProxy
    delegate :disable_ddl_transaction, to: :migration
  end
end
