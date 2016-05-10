class CreateIndexOnBuildsRepositoryIdAndIdDesc < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_builds_on_repository_id_and_id_desc ON builds (repository_id, id DESC NULLS LAST)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_on_repository_id_and_id_desc"
  end
end
