class CreateHistoriesTable < ActiveRecord::Migration[4.2]
   def self.up
     create_table :histories do |t|
       t.string :message # title, name, or object_id
       t.string :username
       t.integer :item
       t.string :table
       t.integer :month, :limit => 2
       t.integer :year, :limit => 5
       t.timestamps null: false
    end
    add_index(:histories, [:item, :table, :month, :year])
  end

  def self.down
    drop_table :histories
  end
end
