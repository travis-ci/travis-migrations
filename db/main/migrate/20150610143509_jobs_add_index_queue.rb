class JobsAddIndexQueue < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_queue ON jobs (queue)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_queue"
  end
end
