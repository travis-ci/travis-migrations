class AddCronTable < ActiveRecord::Migration

  def up
    create_table :crons do |t|
      t.references :branch
      t.string :interval, :null => false
      t.boolean :disable_by_build, :default => true, :null => false
      t.timestamps null: false
    end
  end

  def down
    drop_table :crons
  end
end
