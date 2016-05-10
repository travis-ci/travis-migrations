class JobsAddIndexCreatedAt < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_created_at ON jobs (created_at)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_created_at"
  end
end
