class AddNextRunLastRunToCrons < ActiveRecord::Migration[4.2]
  def up
    unless column_exists? :crons, :next_run
        add_column :crons, :next_run, :datetime
    end
    unless column_exists? :crons, :last_run
        add_column :crons, :last_run, :datetime
    end
  end

  def down
    remove_column :crons, :next_run, :datetime
    remove_column :crons, :last_run, :datetime
  end
end
