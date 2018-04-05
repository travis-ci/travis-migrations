class AddActiveOnOrg < ActiveRecord::Migration

  def change
    add_reference :installations, :added_by_id, index: true
    add_foreign_key :installations, :users, column: :added_by_id
    add_reference :installations, :removed_by_id, index: true
    add_foreign_key :installations, :users, column: :removed_by_id
    add_column :repositories, :active_on_org, :boolean
    add_column :repositories, :managed_by_installation_on, :timestamp
  end

end
