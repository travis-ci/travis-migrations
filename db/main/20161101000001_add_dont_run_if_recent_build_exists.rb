class AddDontRunIfRecentBuildExists < ActiveRecord::Migration
  def up
    unless column_exists? :crons, :dont_run_if_recent_build_exists
        add_column :crons, :dont_run_if_recent_build_exists, :boolean, :default => false
    end
  end

  def down
    remove_column :crons, :dont_run_if_recent_build_exists
  end
end
