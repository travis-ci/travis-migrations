class AddAbuseTable < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    create_table :abuses do |t|
      t.belongs_to :owner, polymorphic: true
      t.column :request_id, :integer, default: nil
      t.column :level, :integer, null: false
      t.string :reason, null: false
      t.timestamps null: false
    end
    execute "CREATE INDEX CONCURRENTLY index_abuses_on_owner ON abuses(owner_id)"
  end

  def down
    execute "DROP INDEX index_abuses_on_owner"
    drop_table :abuses
  end
end
