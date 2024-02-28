# frozen_string_literal: true

class AddEventTypeToBuilds < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :event_type, :string
  end
end
