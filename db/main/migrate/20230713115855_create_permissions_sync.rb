class CreatePermissionsSync < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions_syncs do |t|
      t.references :user
      t.references :resource, :polymorphic => true
      t.timestamps
    end

  end
end
