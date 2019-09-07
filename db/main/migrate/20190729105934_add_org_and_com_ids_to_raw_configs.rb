class AddOrgAndComIdsToRawConfigs < ActiveRecord::Migration[5.2]
  self.disable_ddl_transaction!

  def change
    add_column :request_raw_configs, :org_id, :bigint
    add_column :request_raw_configurations, :org_id, :bigint

    execute "CREATE UNIQUE INDEX CONCURRENTLY index_request_raw_configs_on_org_id ON request_raw_configs (org_id)"
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_request_raw_configurations_on_org_id ON request_raw_configurations (org_id)"
  end
end
