# frozen_string_literal: true

class UsersAddSuspendedAt < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :suspended_at, :datetime
  end
end
