class IndexJobsOnRepositoryId < ActiveRecord::Migration[4.2]
  include Travis::PostgresVersion
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY #{create_index_existence_check} index_jobs_on_repository_id ON jobs (repository_id)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_repository_id"
  end
end
