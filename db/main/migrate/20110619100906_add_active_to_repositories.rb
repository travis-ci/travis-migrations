# frozen_string_literal: true

class AddActiveToRepositories < ActiveRecord::Migration[4.2]
  def self.up
    add_column :repositories, :is_active, :boolean
  end

  def self.down
    remove_column :repositories, :is_active
  end
end
