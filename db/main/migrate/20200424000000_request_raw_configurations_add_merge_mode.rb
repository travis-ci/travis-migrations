class RequestRawConfigurationsAddMergeMode < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :request_raw_configurations, :merge_mode, :string, default: nil
    add_column :deleted_request_raw_configurations, :merge_mode, :string, default: nil
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :request_raw_configurations, :merge_mode
      remove_column :deleted_request_raw_configurations, :merge_mode
    end
  end
end
