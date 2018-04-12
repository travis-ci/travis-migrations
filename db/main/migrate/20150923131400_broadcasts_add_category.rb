class BroadcastsAddCategory < ActiveRecord::Migration[4.2]
  def change
    add_column :broadcasts, :category, :string
  end
end
