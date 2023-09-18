# frozen_string_literal: true

class IndexJobsConfigId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_jobs_on_config_id ON requests (config_id)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_jobs_on_config_id'
  end
end
