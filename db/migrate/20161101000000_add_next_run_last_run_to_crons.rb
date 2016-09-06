class AddNextRunLastRunToCrons < ActiveRecord::Migration
  def up
    add_column :crons, :next_run, :datetime
    add_column :crons, :last_run, :datetime
  end

  def down
    remove_column :crons, :next_run, :datetime
    remove_column :crons, :last_run, :datetime
  end
end
