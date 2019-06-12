class AddHistoryMigrationStatusToRepositories < ActiveRecord::Migration[5.2]
  def change
    add_column :repositories, :history_migration_status, :string
  end
end
