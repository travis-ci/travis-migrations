class AddConcurrencyToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    change_table :subscriptions do |t|
      t.integer :concurrency
    end
  end
end
