class IndexJobsOnOwnerWhereStateRunning < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_owner_where_state_running ON jobs (owner_id, owner_type) WHERE state IN ('queued', 'received', 'started')"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_owner_where_state_running"
  end
end
