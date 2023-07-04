class BuildsAddIndexRepositoryId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_builds_on_repository_id ON builds (repository_id)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_builds_on_repository_id'
  end
end
