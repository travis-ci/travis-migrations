# frozen_string_literal: true

class CreateEmails < ActiveRecord::Migration[4.2]
  def change
    create_table :emails do |t|
      t.integer :user_id
      t.string :email
      t.timestamps null: false
    end

    add_index :emails, :user_id
    add_index :emails, :email
  end
end
