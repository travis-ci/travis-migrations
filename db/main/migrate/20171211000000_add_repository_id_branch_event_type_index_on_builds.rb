class AddRepositoryIdBranchEventTypeIndexOnBuilds < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_builds_on_repository_id_and_branch_and_event_type ON builds (repository_id, branch, event_type) WHERE state IN ('created', 'queued', 'received')"
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_builds_on_repository_id_and_branch_and_event_type'
  end
end
