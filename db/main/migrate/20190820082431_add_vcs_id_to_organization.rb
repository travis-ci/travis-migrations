class AddVcsIdToOrganization < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :organizations, :vcs_id, :string, default: nil

    add_index :organizations, %i[vcs_id vcs_type], unique: true
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :organizations, :vcs_id
    end
  end
end
