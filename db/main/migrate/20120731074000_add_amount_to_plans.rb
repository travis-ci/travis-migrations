class AddAmountToPlans < ActiveRecord::Migration[4.2]
  def change
    change_table :plans do |t|
      t.integer :amount
    end
  end
end
