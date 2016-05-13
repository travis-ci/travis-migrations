class BuildsDropIndexOnRepositoryIdAndIdDesc < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_builds_on_repository_id_and_id_desc"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_builds_on_repository_id_and_id_desc ON builds (repository_id, id DESC NULLS LAST)"
  end
end
