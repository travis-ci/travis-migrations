class RemoveTypeIndices < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_requests_on_event_type'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_jobs_on_owner_type'
  end

  def down
    execute 'CREATE INDEX CONCURRENTLY index_requests_on_event_type ON requests(event_type)'
    execute 'CREATE INDEX CONCURRENTLY index_jobs_on_owner_type ON jobs(owner_type)'
  end
end
