class AddCanBuildToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :can_build, :boolean, default: true
  end
end

