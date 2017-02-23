class JobsAddStage < ActiveRecord::Migration
  def change
    add_column :jobs, :stage, :string
  end
end
