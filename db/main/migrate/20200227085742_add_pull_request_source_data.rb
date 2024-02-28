# frozen_string_literal: true

class AddPullRequestSourceData < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :pull_requests, :base_repo_slug, :string, default: nil
    add_column :pull_requests, :base_repo_vcs_id, :string, default: nil
    add_column :pull_requests, :base_ref, :string, default: nil

    add_column :deleted_pull_requests, :base_repo_slug, :string, default: nil
    add_column :deleted_pull_requests, :base_repo_vcs_id, :string, default: nil
    add_column :deleted_pull_requests, :base_ref, :string, default: nil
  end
end
