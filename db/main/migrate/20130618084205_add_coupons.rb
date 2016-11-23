class AddCoupons < ActiveRecord::Migration
  def up
    create_table :coupons do |t|
      t.integer :percent_off
      t.string :coupon_id
      t.datetime :redeem_by
      t.integer :amount_off
      t.string :duration
      t.integer :duration_in_months
      t.integer :max_redemptions
      t.integer :redemptions
    end
  end

  def down
    drop_table :coupons
  end
end
