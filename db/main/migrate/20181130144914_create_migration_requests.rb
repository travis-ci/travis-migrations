class CreateMigrationRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :migration_requests do |t|
      t.string :owner_name, null: false
      t.string :owner_type, null: false
      t.date :accepted_at
      t.timestamps
    end
  end
end
