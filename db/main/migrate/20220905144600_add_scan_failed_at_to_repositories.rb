# frozen_string_literal: true

class AddScanFailedAtToRepositories < ActiveRecord::Migration[5.2]
  def change
    add_column :repositories, :scan_failed_at, :timestamp
  end
end
