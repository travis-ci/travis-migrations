class IndexBranchesOnRepositoryIdAndNameAndId < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_branches_on_repository_id_and_name_and_id ON branches (repository_id, name, id)"
    execute "DROP INDEX CONCURRENTLY index_branches_on_repository_id_and_name"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_branches_on_repository_id_and_name ON branches (repository_id, name)"
    execute "DROP INDEX CONCURRENTLY index_branches_on_repository_id_and_name_and_id"
  end
end
