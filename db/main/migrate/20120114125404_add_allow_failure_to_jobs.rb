class AddAllowFailureToJobs < ActiveRecord::Migration[4.2]
  def self.up
    add_column :jobs, :allow_failure, :boolean, :default => false
  end

  def self.down
    remove_column :jobs, :allow_failure
  end
end
