# frozen_string_literal: true

class AddIndexOnLastSeenAtToWorkers < ActiveRecord::Migration[4.2]
  def change
    add_index :workers, :last_seen_at
  end
end
