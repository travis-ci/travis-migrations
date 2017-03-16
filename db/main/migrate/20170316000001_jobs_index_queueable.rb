class JobsIndexQueueable < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :jobs, :queueable, algorithm: :concurrently
  end
end
