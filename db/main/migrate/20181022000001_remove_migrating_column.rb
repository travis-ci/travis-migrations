class RemoveMigrating < ActiveRecord::Migration[4.2]
  def change
    remove_column :repositories, :migrating, :string
    remove_column :organizations, :migrating, :string
    remove_column :users, :migrating, :string
  end
end
