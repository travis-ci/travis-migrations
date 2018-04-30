class IndexRepositoriesOnOwnerNameAndName < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_owner_name_and_name ON repositories (owner_name, name) WHERE invalidated_at IS NULL"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_repositories_on_owner_name_and_name"
  end
end
