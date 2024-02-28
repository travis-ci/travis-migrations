# frozen_string_literal: true

class CreateAnnotations < ActiveRecord::Migration[4.2]
  def change
    create_table :annotations do |t|
      t.integer :job_id, null: false
      t.string :url
      t.text :description, null: false
      t.string :image_url
      t.string :image_alt

      t.timestamps null: false
    end
  end
end
