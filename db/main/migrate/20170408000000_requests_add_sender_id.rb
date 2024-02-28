# frozen_string_literal: true

class RequestsAddSenderId < ActiveRecord::Migration[4.2]
  def change
    change_table :requests do |t|
      t.belongs_to :sender, polymorphic: true
    end
  end
end
