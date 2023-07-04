# frozen_string_literal: true

class DropAnnotations < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    drop_table :annotations
    drop_table :annotation_providers
  end

  def down
    create_table :annotations do |t|
      t.integer :job_id, null: false
      t.string :url
      t.text :description, null: false

      t.timestamps null: false

      t.integer :annotation_provider_id, null: false
      add_column :annotations, :status, :string
    end
    execute 'CREATE INDEX CONCURRENTLY index_annotations_on_job_id ON annotations (job_id)'

    create_table :annotation_providers do |t|
      t.string :name
      t.string :api_username
      t.string :api_key

      t.timestamps null: false
    end
  end
end
