class AddIdxCommitsRepoCreated < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :commits, %i[repository_id created_at],
              algorithm: :concurrently,
              name: 'idx_commits_repo_created',
              if_not_exists: true
  end

  def down
    remove_index :commits, name: 'idx_commits_repo_created', if_exists: true
  end
end
