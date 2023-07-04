# frozen_string_literal: true

class BuildsAddReceivedAt < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :received_at, :datetime
  end
end
