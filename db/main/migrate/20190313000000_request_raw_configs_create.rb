class RequestRawConfigsCreate < ActiveRecord::Migration[4.2]
  def change
    create_table :request_raw_configs do |t|
      t.text :config
      t.integer :repository_id
      t.string :key, size: 32, null: false
    end

    add_index :request_raw_configs, %i[repository_id key]

    create_table :request_raw_configurations do |t|
      t.integer :request_id
      t.integer :request_raw_config_id
      t.string :source
    end

    add_index :request_raw_configurations, :request_id
    add_index :request_raw_configurations, :request_raw_config_id
  end
end
