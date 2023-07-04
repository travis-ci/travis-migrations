class DropIndexOnRepositoriesBuildsAndCommits < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX CONCURRENTLY index_repositories_on_lower_owner_name'
    execute 'DROP INDEX CONCURRENTLY index_repositories_on_owner_type'
    execute 'DROP INDEX CONCURRENTLY index_commits_on_repository_id'
    execute 'DROP INDEX CONCURRENTLY index_builds_on_number'
  end

  def down
    execute 'CREATE INDEX CONCURRENTLY index_repositories_on_lower_owner_name ON repositories (lower_owner_name)'
    execute 'CREATE INDEX CONCURRENTLY index_repositories_on_owner_type ON repositories (owner_type)'
    execute 'CREATE INDEX CONCURRENTLY index_commits_on_repository_id ON commits (repository_id)'
    execute 'CREATE INDEX CONCURRENTLY index_builds_on_number ON builds (number)'
  end
end
