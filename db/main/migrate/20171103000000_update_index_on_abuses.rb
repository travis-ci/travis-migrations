class UpdateIndexOnAbuses < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    remove_index :abuses, :owner if index_exists?(:abuses, :owner)
    add_index :abuses, [:owner_id, :owner_type, :level], unique: true, algorithm: :concurrently if !index_exists?(:abuses, [:owner_id, :owner_type, :level])
  end

  def down
    remove_index :abuses, [:owner_id, :owner_type, :level] if index_exists?(:abuses, [:owner_id, :owner_type, :level])
    add_index :abuses, [:owner], algorithm: :concurrently if !index_exists?(:abuse, :owner)
  end
end
