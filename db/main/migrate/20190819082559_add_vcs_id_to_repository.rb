# frozen_string_literal: true

class AddVcsIdToRepository < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :repositories, :vcs_id, :string, default: nil

    execute 'CREATE INDEX CONCURRENTLY index_repositories_on_vcs_id_and_vcs_type ON repositories (vcs_id, vcs_type);'
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :repositories, :vcs_id
    end
  end
end
