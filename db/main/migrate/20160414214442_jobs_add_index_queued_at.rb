class JobsAddIndexQueuedAt < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_queued_at ON jobs (queued_at)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_queued_at"
  end
end
