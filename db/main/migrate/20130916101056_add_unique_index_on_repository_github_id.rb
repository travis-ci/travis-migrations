# frozen_string_literal: true

class AddUniqueIndexOnRepositoryGithubId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX index_repositories_on_github_id'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_repositories_on_github_id ON repositories(github_id)'
  end

  def down; end
end
