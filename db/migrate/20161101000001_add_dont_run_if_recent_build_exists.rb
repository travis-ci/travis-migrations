class AddDontRunIfRecentBuildExists < ActiveRecord::Migration
  def up
    add_column :crons, :dont_run_if_recent_build_exists, :boolean, :default => false
  end

  def down
    remove_column :crons, :dont_run_if_recent_build_exists
  end
end
