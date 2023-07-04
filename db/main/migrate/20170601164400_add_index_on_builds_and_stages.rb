class AddIndexOnBuildsAndStages < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_builds_on_repository_id_and_branch_and_event_type_and_id ON builds (repository_id, branch, event_type, id)'
    execute 'CREATE INDEX CONCURRENTLY index_stages_on_build_id ON stages (build_id)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_builds_on_repository_id_and_branch_and_event_type_and_id'
    execute 'DROP INDEX CONCURRENTLY index_stages_on_build_id'
  end
end
