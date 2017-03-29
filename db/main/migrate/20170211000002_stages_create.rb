class StagesCreate < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.belongs_to :build
      t.integer :number
      t.string :name
    end
  end
end
