class AddRoleToMemberships < ActiveRecord::Migration[4.2]
  def up
    add_column :memberships, :role, :string
  end

  def down
    remove_column :memberships, :role
  end
end
