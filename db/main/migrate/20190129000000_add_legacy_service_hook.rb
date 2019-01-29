class AddLegacyServiceHook < ActiveRecord::Migration[5.2]
  include Travis::PostgresVersion

  def change
    change_table :repositories do |t|
      t.column :legacy_service_hook, :boolean
    end
  end
end
