class AddComIdToBuildConfigs < ActiveRecord::Migration[5.2]
  self.disable_ddl_transaction!

  def change
    add_column :build_configs, :com_id, :bigint
    add_column :deleted_build_configs, :com_id, :bigint

    execute "CREATE UNIQUE INDEX CONCURRENTLY index_build_configs_on_com_id ON build_configs (com_id)"
  end
end
