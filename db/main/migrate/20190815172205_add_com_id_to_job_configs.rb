# frozen_string_literal: true

class AddComIdToJobConfigs < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :job_configs, :com_id, :bigint
    add_column :deleted_job_configs, :com_id, :bigint

    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_job_configs_on_com_id ON job_configs (com_id)'
  end
end
