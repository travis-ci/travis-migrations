class AddDeletedAtToOrganization < ActiveRecord::Migration[7.0]
  def change
    add_column :organizations, :deleted_at, :datetime
    add_index :organizations, :deleted_at
  end
end
