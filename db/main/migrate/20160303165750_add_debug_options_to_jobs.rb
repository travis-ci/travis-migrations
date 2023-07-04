class AddDebugOptionsToJobs < ActiveRecord::Migration[4.2]
  def up
    add_column :jobs, :debug_options, :text
  end

  def down
    remove_column :jobs, :debug_options
  end
end
