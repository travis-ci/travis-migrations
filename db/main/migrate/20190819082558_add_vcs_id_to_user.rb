# frozen_string_literal: true

class AddVcsIdToUser < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :users, :vcs_id, :string, default: nil

    execute 'CREATE INDEX CONCURRENTLY index_users_on_vcs_id_and_vcs_type ON users (vcs_id, vcs_type);'
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :users, :vcs_id
    end
  end
end
