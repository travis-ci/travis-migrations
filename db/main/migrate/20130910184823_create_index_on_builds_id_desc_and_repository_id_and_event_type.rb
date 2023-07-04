# frozen_string_literal: true

class CreateIndexOnBuildsIdDescAndRepositoryIdAndEventType < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_builds_on_id_repository_id_and_event_type_desc ON builds (id DESC, repository_id, event_type);'
  end

  def down
    execute 'DROP INDEX index_builds_on_id_repository_id_and_event_type_desc;'
  end
end
