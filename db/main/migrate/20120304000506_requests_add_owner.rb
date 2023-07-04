# frozen_string_literal: true

class RequestsAddOwner < ActiveRecord::Migration[4.2]
  def change
    change_table :requests do |t|
      t.references :owner, polymorphic: true
    end
  end
end
