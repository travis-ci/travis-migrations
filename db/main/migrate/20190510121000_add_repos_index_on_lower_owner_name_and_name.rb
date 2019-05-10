class AddReposIndexOnLowerOwnerNameAndName < ActiveRecord::Migration[5.2]
  self.disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY IF NOT EXISTS index_repositories_on_lower_owner_name_and_name ON repositories (LOWER(owner_name), LOWER(name)) WHERE invalidated_at IS NULL'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_repositories_on_lower_owner_name_and_name'
  end
end

