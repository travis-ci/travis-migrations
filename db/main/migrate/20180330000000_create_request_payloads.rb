# frozen_string_literal: true

class CreateRequestPayloads < ActiveRecord::Migration[4.2]
  def up
    create_table :request_payloads do |t|
      t.integer :request_id, null: false
      t.text :payload
      t.boolean :archived, default: false
      t.timestamp :created_at
    end

    add_index :request_payloads, :request_id
    add_index :request_payloads, %i[created_at archived]
  end

  def down
    drop_table :request_payloads
  end
end
