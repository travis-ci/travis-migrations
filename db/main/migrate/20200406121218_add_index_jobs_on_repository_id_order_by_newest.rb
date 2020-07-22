class AddIndexJobsOnRepositoryIdOrderByNewest < ActiveRecord::Migration[5.2]
    disable_ddl_transaction!
  
    def up
      execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_jobs_on_repository_id_order_by_newest on jobs (repository_id, id desc)"
    end
  
    def down
      execute "DROP INDEX CONCURRENTLY index_jobs_on_repository_id_order_by_newest"
    end
end