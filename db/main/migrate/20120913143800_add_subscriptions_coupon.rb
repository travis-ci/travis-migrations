class AddSubscriptionsCoupon < ActiveRecord::Migration
  def change
    change_table :subscriptions do |t|
      t.string :coupon
    end
  end
end
