class UpdateIndexOnAbuses < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    remove_index :abuses, :owner if index_exists?(:abuses, :owner)
    add_index :abuses, %i[owner_id owner_type level], unique: true, algorithm: :concurrently unless index_exists?(:abuses, %i[owner_id owner_type level])
  end

  def down
    remove_index :abuses, %i[owner_id owner_type level] if index_exists?(:abuses, %i[owner_id owner_type level])
    add_index :abuses, [:owner], algorithm: :concurrently unless index_exists?(:abuse, :owner)
  end
end
