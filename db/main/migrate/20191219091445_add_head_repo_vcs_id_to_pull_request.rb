class AddHeadRepoVcsIdToPullRequest < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :pull_requests, :head_repo_vcs_id, :string, default: nil

    execute 'CREATE INDEX CONCURRENTLY index_pull_requests_on_head_repo_vcs_id ON pull_requests (head_repo_vcs_id);'
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :pull_requests, :head_repo_vcs_id
    end
  end
end
