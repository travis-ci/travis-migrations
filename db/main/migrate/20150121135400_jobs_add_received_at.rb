# frozen_string_literal: true

class JobsAddReceivedAt < ActiveRecord::Migration[4.2]
  def change
    add_column :jobs, :received_at, :datetime
  end
end
