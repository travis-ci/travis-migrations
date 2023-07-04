class AddActiveFlagToCrons < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def change
    change_table :crons do |t|
      t.boolean :active, default: true
    end

    add_index :crons, :next_run, where: '(active IS TRUE)', algorithm: :concurrently
  end
end
