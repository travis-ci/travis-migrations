# frozen_string_literal: true

class IndexBuildsOnMultiple < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY IF NOT EXISTS index_builds_on_repo_branch_event_type_and_private ON builds (repository_id, branch, event_type, private)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_builds_on_repo_branch_event_type_and_private'
  end
end
