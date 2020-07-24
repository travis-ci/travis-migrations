class IndexJobsOnRepositoryId < ActiveRecord::Migration
    self.disable_ddl_transaction!
  
    def up
      execute "CREATE INDEX CONCURRENTLY index_jobs_on_repository_id ON jobs (repository_id)"
    end
  
    def down
      execute "DROP INDEX CONCURRENTLY IF EXISTS index_jobs_on_repository_id"
    end
  end