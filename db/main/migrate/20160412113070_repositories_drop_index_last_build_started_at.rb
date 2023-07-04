class RepositoriesDropIndexLastBuildStartedAt < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX CONCURRENTLY index_repositories_on_last_build_started_at'
  end

  def down
    execute 'CREATE INDEX CONCURRENTLY index_repositories_on_last_build_started_at ON builds (last_build_started_at)'
  end
end
