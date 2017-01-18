class RenameActiveToEnabled < ActiveRecord::Migration
  def change
    rename_column :repositories, :active, :enabled
  end
end
