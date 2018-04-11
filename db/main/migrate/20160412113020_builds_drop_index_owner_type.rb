class BuildsDropIndexOwnerType < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_builds_on_owner_type"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_builds_on_owner_type ON builds (owner_type)"
  end
end
