class RemoveUnusedJobColumns < ActiveRecord::Migration[4.2]
  def change
    remove_column :jobs, :status
    remove_column :jobs, :job_id
    remove_column :jobs, :retries
  end
end
