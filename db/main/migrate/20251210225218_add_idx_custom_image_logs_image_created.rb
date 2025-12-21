class AddIdxCustomImageLogsImageCreated < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :custom_image_logs, %i[custom_image_id created_at],
              algorithm: :concurrently,
              name: 'idx_custom_image_logs_image_created',
              if_not_exists: true
  end

  def down
    remove_index :custom_image_logs, name: 'idx_custom_image_logs_image_created', if_exists: true
  end
end
