class CreateSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :subscriptions do |t|
      t.string :cc_token
      t.datetime :valid_to
      t.belongs_to :owner, :polymorphic => true
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :zip_code
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :country
      t.string :vat_id
      t.string :customer_id
      t.timestamps
    end
  end
end
