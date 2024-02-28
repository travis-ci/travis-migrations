# frozen_string_literal: true

class AddMissingIndexes < ActiveRecord::Migration[4.2]
  def self.up
    add_index :repositories, :last_build_started_at
    add_index :repositories, %i[owner_name name]
    add_index :builds,       %i[repository_id parent_id started_at]
  end

  def self.down
    remove_index :repositories, :last_build_started_at
    remove_index :repositories, %i[owner_name name]
    remove_index :builds,       %i[repository_id parent_id started_at]
  end
end
