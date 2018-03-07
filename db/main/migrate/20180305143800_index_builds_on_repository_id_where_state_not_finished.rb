class IndexBuildsOnRepositoryIdWhereStateNotFinished < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_builds_on_repository_id_where_state_not_finished ON builds (repository_id) WHERE state IN ('created', 'queued', 'received', 'started');"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_on_repository_id_where_state_not_finished;"
  end
end
