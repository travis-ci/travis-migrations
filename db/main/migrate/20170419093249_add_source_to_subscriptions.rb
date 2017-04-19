class AddSourceToSubscriptions < ActiveRecord::Migration
  def change
    add_column :source, :string, :default => "stripe"
  end
end
