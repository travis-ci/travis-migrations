class BuildsAddIndexRepositoryIdAndNumberAndEventType < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_builds_on_repository_id_and_number_and_event_type ON builds (repository_id, number, event_type)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_on_repository_id_and_number_and_event_type"
  end
end
