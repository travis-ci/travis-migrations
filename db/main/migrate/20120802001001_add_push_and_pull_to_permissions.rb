class AddPushAndPullToPermissions < ActiveRecord::Migration[4.2]
  def change
    add_column :permissions, :push, :boolean, :default => false
    add_column :permissions, :pull, :boolean, :default => false
    change_column_default :permissions, :admin, false
  end
end

