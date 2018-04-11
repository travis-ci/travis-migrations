class CreateTrialAllowances < ActiveRecord::Migration[4.2]
  def change
    create_table :trial_allowances do |t|
      t.integer :trial_id
      t.integer :creator_id
      t.string  :creator_type
      t.integer :builds_allowed
      t.integer :builds_remaining
      t.timestamps
    end
    add_index :trial_allowances, :trial_id
    add_index :trial_allowances, [:creator_id, :creator_type]
  end
end
