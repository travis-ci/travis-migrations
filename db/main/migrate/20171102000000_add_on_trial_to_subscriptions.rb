class AddOnTrialToSubscriptions < ActiveRecord::Migration
  def change
    change_table :subscriptions do |t|
      t.boolean :on_trial, default: false, allow_null: false
    end
  end
end
