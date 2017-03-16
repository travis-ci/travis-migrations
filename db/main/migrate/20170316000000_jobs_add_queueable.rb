class JobsAddQueueable < ActiveRecord::Migration
  def change
    add_column :jobs, :queueable, :boolean
  end
end
