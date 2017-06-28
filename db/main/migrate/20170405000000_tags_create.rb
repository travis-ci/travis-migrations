class TagsCreate < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.belongs_to :repository
      t.string :name
      t.integer :last_build_id
      t.boolean :exists_on_github
      t.timestamps
    end
  end
end
