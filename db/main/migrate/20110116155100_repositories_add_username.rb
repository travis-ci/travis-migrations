# frozen_string_literal: true

class RepositoriesAddUsername < ActiveRecord::Migration[4.2]
  def self.up
    change_table :repositories do |t|
      t.string :username
    end
  end

  def self.down
    change_table :repositories do |t|
      t.remove :username
    end
  end
end
