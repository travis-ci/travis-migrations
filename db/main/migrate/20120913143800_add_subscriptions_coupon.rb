# frozen_string_literal: true

class AddSubscriptionsCoupon < ActiveRecord::Migration[4.2]
  def change
    change_table :subscriptions do |t|
      t.string :coupon
    end
  end
end
