class AddIndexRepositoryIdOnPullRequests < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_pull_requests_on_repository_id_and_number ON pull_requests (repository_id, (number::integer));"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_pull_requests_on_repository_id_and_number"
  end
end
