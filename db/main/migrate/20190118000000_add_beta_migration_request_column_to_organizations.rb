class AddBetaMigrationRequestColumnToOrganizations < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :beta_migration_request_id, :integer
  end
end
