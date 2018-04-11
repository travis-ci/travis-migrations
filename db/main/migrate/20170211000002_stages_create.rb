class StagesCreate < ActiveRecord::Migration[4.2]
  def change
    create_table :stages do |t|
      t.belongs_to :build
      t.integer :number
      t.string :name
    end
  end
end
