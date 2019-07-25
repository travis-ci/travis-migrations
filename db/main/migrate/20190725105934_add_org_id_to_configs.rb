class AddOrgIdToConfigs < ActiveRecord::Migration[5.2]
  self.disable_ddl_transaction!

  def change
    add_column :job_configs, :org_id, :bigint
    add_column :deleted_job_configs, :org_id, :bigint
    add_column :build_configs, :org_id, :bigint
    add_column :deleted_build_configs, :org_id, :bigint
    add_column :request_configs, :org_id, :bigint
    add_column :deleted_request_configs, :org_id, :bigint
    add_column :request_yaml_configs, :org_id, :bigint
    add_column :deleted_request_yaml_configs, :org_id, :bigint
    add_column :request_payloads, :org_id, :bigint
    add_column :deleted_request_payloads, :org_id, :bigint

    execute "CREATE UNIQUE INDEX CONCURRENTLY index_job_configs_on_org_id ON job_configs (org_id)"
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_build_configs_on_org_id ON build_configs (org_id)"
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_request_configs_on_org_id ON request_configs (org_id)"
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_request_yaml_configs_on_org_id ON request_yaml_configs (org_id)"
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_request_payloads_on_org_id ON request_payloads (org_id)"
  end
end
