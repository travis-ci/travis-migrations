class CreateRepositoryMigrationLocks < ActiveRecord::Migration[4.2]
  def change
    create_table :repository_migration_locks
  end
end
