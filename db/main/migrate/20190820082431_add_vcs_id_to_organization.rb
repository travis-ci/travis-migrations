class AddVcsIdToOrganization < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :organizations, :vcs_id, :string, default: nil

    execute 'CREATE INDEX CONCURRENTLY index_organizations_on_vcs_id_and_vcs_type ON organizations (vcs_id, vcs_type);'
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :organizations, :vcs_id
    end
  end
end
