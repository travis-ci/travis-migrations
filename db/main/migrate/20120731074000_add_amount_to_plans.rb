class AddAmountToPlans < ActiveRecord::Migration
  def change
    change_table :plans do |t|
      t.integer :amount
    end
  end
end
