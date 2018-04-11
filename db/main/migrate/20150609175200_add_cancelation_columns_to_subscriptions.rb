class AddCancelationColumnsToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    change_table :subscriptions do |t|
      t.datetime :canceled_at
      t.integer :canceled_by_id
    end
  end
end
