class UpdateIndexOnAbuses < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    remove_index :abuses, :owner if index_exists?(:abuses, :owner)
    add_index :abuses, [:owner_id, :owner_type, :level], unique: true, algorithm: :concurrently
  end

  def down
    remove_index :abuses, [:owner_id, :owner_type, :level]
    add_index :abuses, [:owner_id], algorithm: :concurrently
  end
end
