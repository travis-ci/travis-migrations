class AddSourceToSubscriptions < ActiveRecord::Migration
  def change
    add_column :source, :string, :null => false
  end
end
