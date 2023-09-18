# frozen_string_literal: true

class AlterBuildsUniqueNumberIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_builds_repository_id_unique_number_new ON builds(repository_id, unique_number) WHERE unique_number IS NOT NULL AND unique_number > 0'
    execute 'DROP INDEX CONCURRENTLY index_builds_repository_id_unique_number'
    execute 'ALTER INDEX index_builds_repository_id_unique_number_new RENAME TO index_builds_repository_id_unique_number'
  end

  def down
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_builds_repository_id_unique_number_new ON builds(repository_id, unique_number) WHERE unique_number IS NOT NULL'
    execute 'DROP INDEX CONCURRENTLY index_builds_repository_id_unique_number'
    execute 'ALTER INDEX index_builds_repository_id_unique_number_new RENAME TO index_builds_repository_id_unique_number'
  end
end
