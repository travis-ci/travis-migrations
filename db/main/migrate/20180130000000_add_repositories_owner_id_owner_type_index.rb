class AddRepositoriesOwnerIdOwnerTypeIndex < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_owner_id_owner_type ON repositories (owner_id, owner_type)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_repositories_on_owner_id_owner_type"
  end
end
