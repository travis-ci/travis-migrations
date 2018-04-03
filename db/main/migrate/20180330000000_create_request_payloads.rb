class CreateRequestPayloads < ActiveRecord::Migration
  def up
    create_table :request_payloads do |t|
      t.integer :request_id, null: false
      t.text :payload
      t.boolean :archived, default: false
    end

    add_index :request_payloads, :request_id
  end

  def down
    drop_table :request_payloads
  end
end
