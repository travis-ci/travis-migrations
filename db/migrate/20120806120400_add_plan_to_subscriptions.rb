class AddPlanToSubscriptions < ActiveRecord::Migration
  def change
    change_table :subscriptions do |t|
      t.string :plan
    end
  end
end
