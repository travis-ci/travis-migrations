# frozen_string_literal: true

class EventsChangeDataToText < ActiveRecord::Migration[4.2]
  def change
    change_column :events, :data, :text
  end
end
