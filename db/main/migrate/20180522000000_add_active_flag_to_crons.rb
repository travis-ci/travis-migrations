class AddActiveFlagToCrons < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def change
    unless column_exists?(:crons, :active)
      change_table :crons do |t|
        t.boolean :active, default: true
      end
    end

    add_index :crons, :next_run, where: "(active IS TRUE)", algorithm: :concurrently
  end
end
