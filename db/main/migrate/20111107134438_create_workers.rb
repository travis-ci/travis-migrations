# frozen_string_literal: true

class CreateWorkers < ActiveRecord::Migration[4.2]
  def change
    create_table :workers do |t|
      t.string :name
      t.string :host
      t.string :state
      t.datetime :last_seen_at
    end

    add_index :workers, %i[name host]
  end
end
