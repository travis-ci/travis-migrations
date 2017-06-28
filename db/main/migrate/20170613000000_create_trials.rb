class CreateTrials < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    create_table :trials do |t|
      t.belongs_to :owner, polymorphic: true
      t.text :chartmogul_customer_uuids, array: true, default: []
      t.string :status, default: 'new'
      t.timestamps null: false
    end
    execute "CREATE INDEX CONCURRENTLY index_trials_on_owner ON trials(owner_id, owner_type)"
  end

  def down
    execute "DROP INDEX index_trials_on_owner"
    drop_table :trials
  end
end
