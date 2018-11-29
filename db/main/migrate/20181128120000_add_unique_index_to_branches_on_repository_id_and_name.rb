class AddUniqueIndexToBranchesOnRepositoryIdAndName < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_branches_on_repository_id_and_name ON branches(repository_id, name)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_branches_on_repository_id_and_name"
  end
end
