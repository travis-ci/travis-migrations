class AddMultipleJobStateIndexesOrderByNewest < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_booting_jobs_on_repository_id_order_by_newest on jobs (repository_id, id desc) where state = 'booting'"
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_canceled_jobs_on_repository_id_order_by_newest on jobs (repository_id, id desc) where state = 'canceled'"
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_created_jobs_on_repository_id_order_by_newest on jobs (repository_id, id desc) where state = 'created'"
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_errored_jobs_on_repository_id_order_by_newest on jobs (repository_id, id desc) where state = 'errored'"
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_failed_jobs_on_repository_id_order_by_newest on jobs (repository_id, id desc) where state = 'failed'"
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_passed_jobs_on_repository_id_order_by_newest on jobs (repository_id, id desc) where state = 'passed'"
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_queued_jobs_on_repository_id_order_by_newest on jobs (repository_id, id desc) where state = 'queued'"
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_received_jobs_on_repository_id_order_by_newest on jobs (repository_id, id desc) where state = 'received'"
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_started_jobs_on_repository_id_order_by_newest on jobs (repository_id, id desc) where state = 'started'"
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_booting_jobs_on_repository_id_order_by_newest'
    execute 'DROP INDEX CONCURRENTLY index_canceled_jobs_on_repository_id_order_by_newest'
    execute 'DROP INDEX CONCURRENTLY index_created_jobs_on_repository_id_order_by_newest'
    execute 'DROP INDEX CONCURRENTLY index_errored_jobs_on_repository_id_order_by_newest'
    execute 'DROP INDEX CONCURRENTLY index_failed_jobs_on_repository_id_order_by_newest'
    execute 'DROP INDEX CONCURRENTLY index_passed_jobs_on_repository_id_order_by_newest'
    execute 'DROP INDEX CONCURRENTLY index_queued_jobs_on_repository_id_order_by_newest'
    execute 'DROP INDEX CONCURRENTLY index_received_jobs_on_repository_id_order_by_newest'
    execute 'DROP INDEX CONCURRENTLY index_started_jobs_on_repository_id_order_by_newest'
  end
end
