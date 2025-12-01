class AddDeletedAtToRepository < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :deleted_at, :datetime
    add_index :repositories, :deleted_at, where: "deleted_at IS NOT NULL AND vcs_type = 'AssemblaOrganization'"
  end
end
