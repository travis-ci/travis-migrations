# frozen_string_literal: true

class IndexBuildsOnCreatedAt < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY IF NOT EXISTS index_builds_on_created_at ON builds (created_at)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_builds_on_created_at'
  end
end
