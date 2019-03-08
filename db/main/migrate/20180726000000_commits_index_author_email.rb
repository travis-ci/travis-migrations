class CommitsIndexAuthorEmail < ActiveRecord::Migration[4.2]
  include Travis::PostgresVersion
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY #{create_index_existence_check} index_commits_on_author_email ON commits (author_email)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_commits_on_author_email"
  end
end
