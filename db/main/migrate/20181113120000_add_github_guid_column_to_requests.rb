# frozen_string_literal: true

class AddGithubGuidColumnToRequests < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def change
    add_column :requests, :github_guid, :text
    add_index :requests, :github_guid, algorithm: :concurrently, unique: true
  end
end
