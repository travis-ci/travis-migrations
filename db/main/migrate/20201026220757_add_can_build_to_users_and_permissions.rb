class AddCanBuildToUsersAndPermissions < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :can_build, :boolean, default: true
    add_column :permissions, :build, :boolean, default: true
  end
end

