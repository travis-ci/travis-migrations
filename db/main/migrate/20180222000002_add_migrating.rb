class AddMigrating < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :migrating, :boolean
    add_column :repositories, :migrated_at, :datetime

    add_column :organizations, :migrating, :boolean
    add_column :organizations, :migrated_at, :datetime

    add_column :users, :migrating, :boolean
    add_column :users, :migrated_at, :datetime
  end
end
