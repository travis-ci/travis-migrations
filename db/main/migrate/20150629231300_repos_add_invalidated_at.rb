# frozen_string_literal: true

class ReposAddInvalidatedAt < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :invalidated_at, :datetime
  end
end
