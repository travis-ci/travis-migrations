class AddEventIdToStripeEvents < ActiveRecord::Migration[4.2]
  def change
    change_table :stripe_events do |t|
      t.string :event_id
    end
    add_index :stripe_events, :event_id
  end
end
