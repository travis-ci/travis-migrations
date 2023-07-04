class IndexCommitsOnRepositoryId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY IF NOT EXISTS index_commits_on_repository_id ON commits (repository_id)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_commits_on_repository_id'
  end
end
