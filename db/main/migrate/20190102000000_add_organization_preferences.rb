class AddOrganizationPreferences < ActiveRecord::Migration[5.2]
  include Travis::PostgresVersion

  def change
    change_table :organizations do |t|
      t.column :preferences, json_type
    end
  end
end
