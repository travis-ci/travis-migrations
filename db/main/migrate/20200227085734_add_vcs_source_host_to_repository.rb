class AddVcsSourceHostToRepository < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :repositories, :vcs_source_host, :string, default: nil
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :repositories, :vcs_source_host
    end
  end
end
