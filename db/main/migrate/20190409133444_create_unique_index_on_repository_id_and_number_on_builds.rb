class CreateUniqueIndexOnRepositoryIdAndNumberOnBuilds < ActiveRecord::Migration[5.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_builds_repository_id_unique_number ON builds(repository_id, unique_number) WHERE unique_number IS NOT NULL"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_repository_id_unique_number"
  end
end
