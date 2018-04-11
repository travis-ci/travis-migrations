class JobsAddOwner < ActiveRecord::Migration[4.2]
  def change
    change_table :jobs do |t|
      t.references :owner, :polymorphic => true
    end
  end
end
