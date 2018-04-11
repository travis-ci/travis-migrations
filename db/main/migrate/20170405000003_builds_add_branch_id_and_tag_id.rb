class BuildsAddBranchIdAndTagId < ActiveRecord::Migration[4.2]
  def change
    change_table :builds do |t|
      t.belongs_to :branch
      t.belongs_to :tag
    end
  end
end
