class AddConfigsJson < ActiveRecord::Migration[5.2]
  def up
    add_column :request_configs, :config_json, :json
    add_column :build_configs, :config_json, :json
    add_column :job_configs, :config_json, :json

    add_column :deleted_request_configs, :config_json, :json
    add_column :deleted_build_configs, :config_json, :json
    add_column :deleted_job_configs, :config_json, :json
  end

  def down
    remove_column :request_configs, :config_json
    remove_column :build_configs, :config_json
    remove_column :job_configs, :config_json

    remove_column :deleted_request_configs, :config_json
    remove_column :deleted_build_configs, :config_json
    remove_column :deleted_job_configs, :config_json
  end
end
