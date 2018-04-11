class CreateUrls < ActiveRecord::Migration[4.2]
  def change
    create_table :urls do |t|
      t.string   :url
      t.string   :code

      t.timestamps null: false
    end
  end
end
