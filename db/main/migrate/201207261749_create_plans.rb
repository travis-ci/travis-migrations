class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.string :coupon
      t.belongs_to :subscription
      t.datetime :valid_from
      t.datetime :valid_to
      t.timestamps
    end
  end
end
