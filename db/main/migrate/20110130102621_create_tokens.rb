# frozen_string_literal: true

class CreateTokens < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tokens do |t|
      t.belongs_to :user
      t.string     :token
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :tokens
  end
end
