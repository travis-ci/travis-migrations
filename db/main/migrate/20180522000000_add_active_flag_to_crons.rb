class AddActiveFlagToCrons < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def change
    unless column_exists?(:crons, :active)
      change_table :crons do |t|
        t.boolean :active, default: true
      end
    end

    unless index_exists?(:crons, :next_run, name: "index_crons_on_next_run")
      add_index :crons, :next_run, where: "(active IS TRUE)", algorithm: :concurrently
    end
  end
end
