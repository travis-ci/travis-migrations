class AddIndexesToJobs < ActiveRecord::Migration[4.2]
  def self.up
    add_index(:jobs, [:queue, :state])
  end

  def self.down
    remove_index(:jobs, :column => [:queue, :state])
  end
end
