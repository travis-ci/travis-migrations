class QueueableJobsIndexJobId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def change
    add_index :queueable_jobs, :job_id, algorithm: :concurrently
  end
end
