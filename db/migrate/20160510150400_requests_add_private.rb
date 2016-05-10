class RequestsAddPrivate < ActiveRecord::Migration
  def up
    change_table :requests do |t|
      t.boolean :private, :default => true
    end
  end

  def down
    remove_column :requests, :private
  end
end
