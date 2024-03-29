# frozen_string_literal: true

class CreateStars < ActiveRecord::Migration[4.2]
  def self.up
    create_table :stars do |t|
      t.integer   :repository_id
      t.integer   :user_id
      t.timestamps null: false
    end

    add_index :stars, :user_id
  end

  def self.down
    drop_table :stars
  end
end
