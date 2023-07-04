# frozen_string_literal: true

class AddHeadRepoVcsIdToDeletedPullRequest < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :deleted_pull_requests, :head_repo_vcs_id, :string, default: nil

    execute 'CREATE INDEX CONCURRENTLY index_deleted_pull_requests_on_head_repo_vcs_id ON deleted_pull_requests (head_repo_vcs_id);'
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :deleted_pull_requests, :head_repo_vcs_id
    end
  end
end
