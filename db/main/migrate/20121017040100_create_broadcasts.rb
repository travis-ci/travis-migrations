class CreateBroadcasts < ActiveRecord::Migration[4.2]
  def change
    create_table :broadcasts do |t|
      t.belongs_to :recipient, :polymorphic => true
      t.string :kind
      t.string :message
      t.boolean :expired
      t.timestamps null: false
    end
  end
end
