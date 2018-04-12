class BuildsAddOwner < ActiveRecord::Migration[4.2]
  def change
    change_table :builds do |t|
      t.references :owner, :polymorphic => true
    end
  end
end

