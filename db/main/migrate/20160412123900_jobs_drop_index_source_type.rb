# frozen_string_literal: true

class JobsDropIndexSourceType < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX CONCURRENTLY index_jobs_on_source_type'
  end

  def down
    execute 'CREATE INDEX CONCURRENTLY index_jobs_on_source_type ON jobs (source_type)'
  end
end
