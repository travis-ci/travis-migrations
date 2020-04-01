class AddIndexJobsOnRepositoryIdAnyValidStateOrderByNewest < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_jobs_on_repository_id_any_valid_state_order_by_newest on jobs (repository_id, id desc) where state = any ('{created,queued,booting,received,passed,started,errored,failed,canceled}'::varchar[])"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_repository_id_any_valid_state_order_by_newest"
  end
end
