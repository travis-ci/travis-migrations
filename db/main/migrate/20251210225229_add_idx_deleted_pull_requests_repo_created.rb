class AddIdxDeletedPullRequestsRepoCreated < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :deleted_pull_requests, %i[repository_id created_at],
              algorithm: :concurrently,
              name: 'idx_deleted_pull_requests_repo_created',
              if_not_exists: true
  end

  def down
    remove_index :deleted_pull_requests, name: 'idx_deleted_pull_requests_repo_created', if_exists: true
  end
end
