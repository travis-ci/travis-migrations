class AddSourceToSubscriptions < ActiveRecord::Migration
  def change
    add_column :source, :string, :default => 'manual', :null => false
  end
end
