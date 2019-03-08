class IndexBuildsOnCreatedAt < ActiveRecord::Migration[4.2]
  include Travis::PostgresVersion
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY #{create_index_existence_check} index_builds_on_created_at ON builds (created_at)"
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_builds_on_created_at'
  end
end
