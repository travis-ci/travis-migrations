class AddQueuedAtToJobs < ActiveRecord::Migration[4.2]
  def change
    add_column :jobs, :queued_at, :datetime
  end
end

