# frozen_string_literal: true

class JobsAddIndexSourceType < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_jobs_on_source_type ON jobs (source_type)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_jobs_on_source_type'
  end
end
