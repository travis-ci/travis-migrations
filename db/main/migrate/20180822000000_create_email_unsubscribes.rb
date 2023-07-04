# frozen_string_literal: true

class CreateEmailUnsubscribes < ActiveRecord::Migration[4.2]
  def change
    create_table :email_unsubscribes do |t|
      t.belongs_to :user, index: true
      t.belongs_to :repository, index: true
      t.timestamps
      t.index %i[user_id repository_id], unique: true
    end
  end
end
