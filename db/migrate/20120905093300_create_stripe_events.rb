class CreateStripeEvents < ActiveRecord::Migration
  def change
    create_table :stripe_events, id: false do |t|
      t.timestamps
      t.text :event_object
      t.string :id
      t.string :event_type
      t.datetime :date
    end

    add_index :stripe_events, :event_type
    add_index :stripe_events, :date
  end
end
