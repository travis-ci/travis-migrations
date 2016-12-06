class AddBillingAdminOnlyToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :billing_admin_only, :boolean
  end
end
