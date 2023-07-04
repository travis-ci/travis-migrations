class AddIndexOnRequestsRepositoryIdAndIdDesc < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_requests_on_repository_id_and_id_desc ON requests (repository_id, id DESC);'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_requests_on_repository_id_and_id_desc'
  end
end
