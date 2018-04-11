class AddOwnerAndTypeIndexToJobs < ActiveRecord::Migration[4.2]
  def self.up
    add_index(:jobs, [:type, :owner_id, :owner_type])
  end

  def self.down
    remove_index(:jobs, [:type, :owner_id, :owner_type])
  end
end
