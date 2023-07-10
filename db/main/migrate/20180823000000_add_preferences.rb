class AddPreferences < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.column :preferences, :jsonb
    end
  end
end
