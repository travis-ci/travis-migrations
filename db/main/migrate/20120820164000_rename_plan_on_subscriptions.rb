class RenamePlanOnSubscriptions < ActiveRecord::Migration[4.2]
  def change
    change_table :subscriptions do |t|
      t.rename(:plan, :selected_plan)
    end
  end
end
