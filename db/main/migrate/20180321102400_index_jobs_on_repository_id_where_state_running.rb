class IndexJobsOnRepositoryIdWhereStateRunning < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_repository_id_where_state_running ON jobs (repository_id) WHERE state IN ('queued', 'received', 'started')"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_repository_id_where_state_running"
  end
end
