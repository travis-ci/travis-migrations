class CommitsIndexAuthorEmail < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_commits_on_author_email ON commits (author_email)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_commits_on_author_email"
  end
end
