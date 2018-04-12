class BuildsAddPrivate < ActiveRecord::Migration[4.2]
  def up
    change_table :builds do |t|
      t.boolean :private
    end
  end

  def down
    remove_column :builds, :private
  end
end
