class AddComIdToMoreTables < ActiveRecord::Migration[5.2]
  self.disable_ddl_transaction!

  def change
    add_column :request_configs, :com_id, :bigint
    add_column :request_yaml_configs, :com_id, :bigint
    add_column :deleted_request_configs, :com_id, :bigint
    add_column :deleted_request_yaml_configs, :com_id, :bigint

    execute "CREATE UNIQUE INDEX CONCURRENTLY index_request_configs_on_com_id ON request_configs (com_id)"
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_request_yaml_configs_on_com_id ON request_yaml_configs (com_id)"
  end
end
