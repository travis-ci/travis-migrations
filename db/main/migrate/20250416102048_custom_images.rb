
class CustomImages < ActiveRecord::Migration[7.0]

  def up
  execute <<~SQL
      CREATE TYPE custom_image_state AS ENUM('pending', 'creating', 'available', 'deleted', 'error');
      CREATE TYPE architecture_type AS ENUM ('x86', 'arm64','ppc64le');
      CREATE TYPE custom_image_log_action AS ENUM ('created','used', 'deleted', 'other');
    SQL

    create_table :custom_images do |t|
      t.references :owner, polymorphic: true
      t.text :name, null: false
      t.integer :usage, default: 0
      t.column :architecture, :architecture_type, null: false
      t.text :google_id
      t.column :state, :custom_image_state, null: false, default: 'pending'
      t.bigint :size_bytes, null: false
      t.text :os_version
      t.string :labels
      t.text :description
      t.timestamps
      t.timestamp :to_be_deleted_at
    end

    add_index :custom_images, %i[owner_id owner_type name], unique: true
    add_index :custom_images, %i[owner_id owner_type state]

    create_table :custom_image_logs do |t|
      t.references :custom_images
      t.column :action, :custom_image_log_action, null: false, default: 'other'
      t.integer :sender_id
      t.timestamps
      t.text :details
    end

    add_index :custom_image_logs, :action
    add_index :custom_image_logs, :created_at

    add_column :jobs, :created_custom_image_id, :integer
    add_column :jobs, :used_custom_image_id, :integer
    add_foreign_key :jobs, :custom_images, column: :created_custom_image_id
    add_foreign_key :jobs, :custom_images, column: :used_custom_image_id

    add_column :deleted_jobs, :created_custom_image_id, :integer
    add_column :deleted_jobs, :used_custom_image_id, :integer
    add_foreign_key :deleted_jobs, :custom_images, column: :created_custom_image_id
    add_foreign_key :deleted_jobs, :custom_images, column: :used_custom_image_id
  end

  def down
    remove_column :jobs, :created_custom_image_id
    remove_column :jobs, :used_custom_image_id
    remove_column :deleted_jobs, :created_custom_image_id
    remove_column :deleted_jobs, :used_custom_image_id
    drop_table :custom_images
    drop_table :custom_image_logs

    execute 'DROP TYPE custom_image_state'
    execute 'DROP TYPE architecture_type'
    execute 'DROP TYPE custom_image_log_action'
  end
end
