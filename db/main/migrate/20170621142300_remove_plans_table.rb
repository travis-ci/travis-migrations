# frozen_string_literal: true

class RemovePlansTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :plans
  end

  def down
    create_table :plans do |t|
      t.string :name
      t.string :coupon
      t.belongs_to :subscription
      t.datetime :valid_from
      t.datetime :valid_to
      t.integer :amount
      t.timestamps
    end
  end
end
