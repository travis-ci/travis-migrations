class AddColumnPriorityToTableJobsAndDeletedJobs < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :jobs, :priority, :integer, default: nil
    add_column :deleted_jobs, :priority, :integer, default: nil
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :jobs, :priority
      remove_column :deleted_jobs, :priority
    end
  end
end
