class DropUnusedIndexesOnJobsAndBuilds < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_jobs_on_repository_id"
    execute "DROP INDEX CONCURRENTLY index_jobs_on_queued_at"
    execute "DROP INDEX CONCURRENTLY index_jobs_on_queue"
    execute "DROP INDEX CONCURRENTLY index_jobs_on_owner_id"

    execute "DROP INDEX CONCURRENTLY index_builds_on_branch"
    execute "DROP INDEX CONCURRENTLY index_builds_on_event_type"
    execute "DROP INDEX CONCURRENTLY index_builds_on_owner_id"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_repository_id ON jobs (repository_id)"
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_queued_at ON jobs (queued_at)"
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_queue ON jobs (queue)"
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_owner_id ON jobs (owner_id)"

    execute "CREATE INDEX CONCURRENTLY index_builds_on_branch ON builds (branch)"
    execute "CREATE INDEX CONCURRENTLY index_builds_on_event_type ON builds (event_type)"
    execute "CREATE INDEX CONCURRENTLY index_builds_on_owner_id ON builds (owner_id)"
  end
end
