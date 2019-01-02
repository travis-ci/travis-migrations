class AddPreferences < ActiveRecord::Migration[4.2]
  include Travis::PostgresVersion

  def change
    change_table :users do |t|
      t.column :preferences, json_type
    end
  end
end
