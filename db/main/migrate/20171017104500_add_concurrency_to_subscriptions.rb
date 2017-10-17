class AddConcurrencyToSubscriptions < ActiveRecord::Migration
  def change
    change_table :subscriptions do |t|
      t.integer :concurrency
    end
  end
end
