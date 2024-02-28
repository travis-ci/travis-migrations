# frozen_string_literal: true

class RenameConfigsJson < ActiveRecord::Migration[5.2]
  def up
    transaction do
      remove_column :request_configs, :config
      rename_column :request_configs, :config_json, :config
    end

    transaction do
      remove_column :build_configs, :config
      rename_column :build_configs, :config_json, :config
    end

    transaction do
      remove_column :job_configs, :config
      rename_column :job_configs, :config_json, :config
    end

    transaction do
      remove_column :deleted_request_configs, :config
      rename_column :deleted_request_configs, :config_json, :config
    end

    transaction do
      remove_column :deleted_build_configs, :config
      rename_column :deleted_build_configs, :config_json, :config
    end

    transaction do
      remove_column :deleted_job_configs, :config
      rename_column :deleted_job_configs, :config_json, :config
    end
  end

  def down
    add_column :request_configs, :config_json, :json
    add_column :build_configs, :config_json, :json
    add_column :job_configs, :config_json, :json

    add_column :deleted_request_configs, :config_json, :json
    add_column :deleted_build_configs, :config_json, :json
    add_column :deleted_job_configs, :config_json, :json
  end

  def transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end
end
