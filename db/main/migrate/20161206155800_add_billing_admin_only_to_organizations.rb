# frozen_string_literal: true

class AddBillingAdminOnlyToOrganizations < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :billing_admin_only, :boolean
  end
end
