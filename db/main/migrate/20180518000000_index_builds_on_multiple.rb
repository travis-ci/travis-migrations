class IndexBuildsOnMultiple < ActiveRecord::Migration[4.2]
  include Travis::PostgresVersion
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY #{create_index_existence_check} index_builds_on_repo_branch_event_type_and_private ON builds (repository_id, branch, event_type, private)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_on_repo_branch_event_type_and_private"
  end
end
