# frozen_string_literal: true

class CommitsIndexCommitterEmail < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY IF NOT EXISTS index_commits_on_committer_email ON commits (committer_email)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_commits_on_committer_email'
  end
end
