class AddColumnRestartedByToTableJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :restarted_by, :integer, default: nil
  end
end
