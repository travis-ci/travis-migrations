# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :events do |t|
      t.belongs_to :source, polymorphic: true
      t.belongs_to :repository
      t.string :event
      t.string :data
      t.timestamps null: false
    end
  end
end
