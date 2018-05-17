class IndexRequestsConfigId < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_requests_on_config_id ON requests (config_id)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_requests_on_config_id"
  end
end
