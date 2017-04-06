class RequestsAddBranchIdAndTagId < ActiveRecord::Migration
  def change
    change_table :requests do |t|
      t.belongs_to :branch
      t.belongs_to :tag
    end
  end
end
