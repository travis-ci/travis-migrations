class AddVcsIdToRepository < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :repositories, :vcs_id, :string, default: nil

    add_index :repositories, %i[vcs_id vcs_type], unique: true
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :repositories, :vcs_id
    end
  end
end
