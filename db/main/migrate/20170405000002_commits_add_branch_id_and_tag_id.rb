class CommitsAddBranchIdAndTagId < ActiveRecord::Migration
  def change
    change_table :commits do |t|
      t.belongs_to :branch
      t.belongs_to :tag
    end
  end
end
