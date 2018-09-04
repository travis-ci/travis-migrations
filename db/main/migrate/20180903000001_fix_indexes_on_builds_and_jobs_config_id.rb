class FixIndexesOnBuildsAndJobsConfigId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX index_builds_on_config_id'
    execute 'CREATE INDEX CONCURRENTLY index_builds_on_config_id ON builds (config_id)'

    execute 'DROP INDEX index_jobs_on_config_id'
    execute 'CREATE INDEX CONCURRENTLY index_jobs_on_config_id ON jobs (config_id)'
  end

  def down
  end
end

