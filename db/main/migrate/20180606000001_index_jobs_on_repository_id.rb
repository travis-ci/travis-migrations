# frozen_string_literal: true

class IndexJobsOnRepositoryId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY IF NOT EXISTS index_jobs_on_repository_id ON jobs (repository_id)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_jobs_on_repository_id'
  end
end
