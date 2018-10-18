class AddMigratingStatus < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :migrating_status, :string
    add_column :organizations, :migrating_status, :string
    add_column :users, :migrating_status, :string
  end
end
