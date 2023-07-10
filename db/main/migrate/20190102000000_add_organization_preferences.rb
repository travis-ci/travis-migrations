class AddOrganizationPreferences < ActiveRecord::Migration[5.2]
  def change
    change_table :organizations do |t|
      t.column :preferences, :jsonb
    end
  end
end
