class CreateBetaMigrationRequestTable < ActiveRecord::Migration[4.2]
  def change
    create_table :beta_migration_requests do |t|
      t.integer  :owner_id
      t.string   :owner_name
      t.string   :owner_type
      t.datetime :created_at
      t.datetime :accepted_at
    end
    add_index :beta_migration_requests, [:owner_type, :owner_id]
  end
end
