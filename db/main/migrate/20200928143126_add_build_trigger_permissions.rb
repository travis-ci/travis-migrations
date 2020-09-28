class AddBuildTriggerPermissions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :memberships, :build_permissioni, :boolean, default: nil
    add_column :permissions, :build, :boolean, default: nil
  end
end
