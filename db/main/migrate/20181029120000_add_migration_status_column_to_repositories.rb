class AddMigrationStatusColumnToRepositories < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :migration_status, :string
  end
end
