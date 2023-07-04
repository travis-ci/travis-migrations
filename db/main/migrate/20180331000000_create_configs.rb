class CreateConfigs < ActiveRecord::Migration[4.2]
  def up
    create_table :request_configs do |t|
      t.integer :repository_id, null: false
      t.string :key, size: 32, null: false
      t.jsonb :config
    end

    create_table :build_configs do |t|
      t.integer :repository_id, null: false
      t.string :key, size: 32, null: false
      t.jsonb :config
    end

    create_table :job_configs do |t|
      t.integer :repository_id, null: false
      t.string :key, size: 32, null: false
      t.jsonb :config
    end

    add_index :request_configs, %i[repository_id key]
    add_index :build_configs, %i[repository_id key]
    add_index :job_configs, %i[repository_id key]

    add_column :requests, :config_id, :integer
    add_column :builds, :config_id, :integer
    add_column :jobs, :config_id, :integer
  end

  def down
    drop_table :request_configs
    drop_table :build_configs
    drop_table :job_configs

    remove_column :requests, :config_id
    remove_column :builds, :config_id
    remove_column :jobs, :config_id
  end
end
