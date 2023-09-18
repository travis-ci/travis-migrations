# frozen_string_literal: true

class CreateCancellations < ActiveRecord::Migration[4.2]
  def change
    create_table :cancellations do |t|
      t.references :subscription, index: true, null: false
      t.references :user
      t.string :plan, null: false
      t.date :subscription_start_date, :cancellation_date, null: false
      t.string :reason
      t.text :reason_details
      t.timestamps
    end
  end
end
