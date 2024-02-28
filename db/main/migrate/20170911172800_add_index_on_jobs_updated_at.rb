# frozen_string_literal: true

class AddIndexOnJobsUpdatedAt < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_jobs_on_updated_at ON jobs (updated_at)'
  end

  def down
    execute 'DROP INDEX index_jobs_on_updated_at'
  end
end
