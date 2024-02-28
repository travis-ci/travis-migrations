# frozen_string_literal: true

class AddSyncInfoToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :in_sync, :boolean
    add_column :users, :synced_at, :timestamp
  end
end
