class JobsAddPrivate < ActiveRecord::Migration
  def up
    change_table :jobs do |t|
      t.boolean :private
    end
  end

  def down
    remove_column :jobs, :private
  end
end
