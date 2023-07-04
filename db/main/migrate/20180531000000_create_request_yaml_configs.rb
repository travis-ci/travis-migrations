class CreateRequestYamlConfigs < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    create_table :request_yaml_configs do |t|
      t.text :yaml
      t.integer :repository_id
      t.string :key, size: 32, null: false
    end
    add_index :request_yaml_configs, %i[repository_id key]
    add_column :requests, :yaml_config_id, :integer
  end

  def down
    drop_table :request_yaml_configs
    remove_column :requests, :yaml_config_id
  end
end
