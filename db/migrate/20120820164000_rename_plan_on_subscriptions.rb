class RenamePlanOnSubscriptions < ActiveRecord::Migration
  def change
    change_table :subscriptions do |t|
      t.rename(:plan, :selected_plan)
    end
  end
end
