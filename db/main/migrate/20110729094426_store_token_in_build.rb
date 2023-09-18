# frozen_string_literal: true

class StoreTokenInBuild < ActiveRecord::Migration[4.2]
  def self.up
    add_column :builds, :token, :string
  end

  def self.down
    remove_column :builds, :token
  end
end
