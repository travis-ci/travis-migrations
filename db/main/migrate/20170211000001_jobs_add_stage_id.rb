class JobsAddStageId < ActiveRecord::Migration[4.2]
  def change
    change_table :jobs do |t|
      t.belongs_to :stage
    end
  end
end
