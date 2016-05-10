class BuildsAddPrivate < ActiveRecord::Migration
  def up
    change_table :builds do |t|
      t.boolean :private, :default => true
    end
  end

  def down
    remove_column :builds, :private
  end
end
