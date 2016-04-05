class AddDependencyTable < ActiveRecord::Migration

  def up
    create_table :dependencies do |t|
      t.references :dependency
      t.references :dependant
    end
  end

  def down
    drop_table :dependencies
  end
end
