class LastActivityAtOnUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :last_activity_at, :timestamp
  end
end
