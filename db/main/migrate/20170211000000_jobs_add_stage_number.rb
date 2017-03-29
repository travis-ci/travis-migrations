class JobsAddStageNumber < ActiveRecord::Migration
  def change
    add_column :jobs, :stage_number, :string
  end
end
