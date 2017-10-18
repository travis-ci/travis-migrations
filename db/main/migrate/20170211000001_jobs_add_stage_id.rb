class JobsAddStageId < ActiveRecord::Migration
  def change
    change_table :jobs do |t|
      t.belongs_to :stage
    end
  end
end
