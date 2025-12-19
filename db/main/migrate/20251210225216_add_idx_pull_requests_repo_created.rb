class AddIdxPullRequestsRepoCreated < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :pull_requests, %i[repository_id created_at],
              algorithm: :concurrently,
              name: 'idx_pull_requests_repo_created',
              if_not_exists: true
  end

  def down
    remove_index :pull_requests, name: 'idx_pull_requests_repo_created', if_exists: true
  end
end
