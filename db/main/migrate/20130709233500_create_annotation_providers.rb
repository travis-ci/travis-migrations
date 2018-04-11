class CreateAnnotationProviders < ActiveRecord::Migration[4.2]
  def change
    create_table :annotation_providers do |t|
      t.string :name
      t.string :api_username
      t.string :api_key

      t.timestamps null: false
    end
  end
end
