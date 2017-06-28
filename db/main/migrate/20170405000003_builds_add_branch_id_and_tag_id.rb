class BuildsAddBranchIdAndTagId < ActiveRecord::Migration
  def change
    change_table :builds do |t|
      t.belongs_to :branch
      t.belongs_to :tag
    end
  end
end
