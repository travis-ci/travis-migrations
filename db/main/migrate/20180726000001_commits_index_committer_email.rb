class CommitsIndexCommitterEmail < ActiveRecord::Migration[4.2]
  include Travis::PostgresVersion
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY #{create_index_existence_check} index_commits_on_committer_email ON commits (committer_email)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_commits_on_committer_email"
  end
end
