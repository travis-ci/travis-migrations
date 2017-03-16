class QueueableJobsCreate < ActiveRecord::Migration
  def change
    create_table :queueable_jobs do |t|
      t.belongs_to :job
    end
  end
end
