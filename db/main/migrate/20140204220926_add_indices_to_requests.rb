class AddIndicesToRequests < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_requests_on_repository_id ON requests(repository_id)'
    execute 'CREATE INDEX CONCURRENTLY index_requests_on_commit_id ON requests(commit_id)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_requests_on_repository_id'
    execute 'DROP INDEX CONCURRENTLY index_requests_on_commit_id'
  end
end
