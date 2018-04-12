class RepositoriesDropIndexOwnerNameName < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_repositories_on_owner_name_and_name"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_owner_name_and_name ON repositories (owner_name, name)"
  end
end

