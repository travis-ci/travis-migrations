# frozen_string_literal: true

class CreateCustomKeysTable < ActiveRecord::Migration[5.2]
  def self.up
    create_table :custom_keys do |t|
      t.integer  :owner_id
      t.string   :owner_type
      t.string   :name
      t.string   :private_key
      t.string   :public_key
      t.string   :fingerprint
      t.text     :description
      t.integer  :added_by
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end

  def self.down
    drop_table :custom_keys
  end
end
