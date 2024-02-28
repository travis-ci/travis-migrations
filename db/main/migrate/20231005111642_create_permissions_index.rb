class CreatePermissionsIndex < ActiveRecord::Migration[7.0]

  def self.up
    add_index :permissions_syncs, [:user_id, :resource_type, :resource_id], name: 'index_permissions_syncs_on_user_and_resource'
    add_index :role_names, :role_type
  end

  def self.down
    remove_index :permissions_syncs, [:user_id, :resource_type, :resource_id], name: 'index_permissions_syncs_on_user_and_resource'
    remove_index :role_names, :role_type
  end
end
