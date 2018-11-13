class CreateRequestPayloadHashes < ActiveRecord::Migration[4.2]
  def up
    create_table :request_payload_hashes, id: false do |t|
      t.belongs_to :repository, null: false
      t.text :hash
    end

    add_index :request_payload_hashes, :hash
  end

  def down
    drop_table :request_payload_hashes
  end
end
