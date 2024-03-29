# frozen_string_literal: true

class CreateRepositories < ActiveRecord::Migration[4.2]
  def self.up
    create_table :repositories do |t|
      t.string   :name
      t.string   :url
      t.integer  :last_duration
      t.datetime :last_built_at
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :repositories
  end
end
