class IndexBuildsOnRepositoryIdEventTypeId < ActiveRecord::Migration[4.2]
  include Travis::PostgresVersion
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY #{create_index_existence_check} index_builds_on_repository_id_event_type_id ON builds (repository_id, event_type, id DESC)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_on_repository_id_event_type_id"
  end
end
