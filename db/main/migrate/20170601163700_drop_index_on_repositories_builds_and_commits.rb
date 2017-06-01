class DropIndexOnRepositoriesBuildsCommits < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_repositories_on_lower_owner_name ON repositories;"
    execute "DROP INDEX CONCURRENTLY index_repositories_on_owner_type ON repositories;"
    execute "DROP INDEX CONCURRENTLY index_commits_on_repository_id ON commits;"
    execute "DROP INDEX CONCURRENTLY index_builds_on_number ON builds;"
  end
end
