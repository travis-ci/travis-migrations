# frozen_string_literal: true

class AddIndexOnRepositoryIdToCommits < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX IF EXISTS index_commits_on_repository_id'
    execute 'CREATE INDEX CONCURRENTLY index_commits_on_repository_id ON commits(repository_id)'
  end

  def down
    execute 'DROP INDEX index_commits_on_repository_id'
  end
end
