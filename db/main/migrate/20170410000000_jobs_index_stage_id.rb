class JobsIndexStageId < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_stage_id ON jobs (stage_id);"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_stage_id"
  end
end
