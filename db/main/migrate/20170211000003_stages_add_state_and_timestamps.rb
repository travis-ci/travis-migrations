class StagesAddStateAndTimestamps < ActiveRecord::Migration
  def change
    change_table :stages do |t|
      t.string :state
      t.timestamp :started_at
      t.timestamp :finished_at
    end
  end
end
