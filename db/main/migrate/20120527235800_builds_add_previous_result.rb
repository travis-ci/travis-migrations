class BuildsAddPreviousResult < ActiveRecord::Migration[4.2]
  def change
    change_table :builds do |t|
      t.integer :previous_result
    end
  end
end
