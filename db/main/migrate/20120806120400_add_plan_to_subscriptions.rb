class AddPlanToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    change_table :subscriptions do |t|
      t.string :plan
    end
  end
end
