# frozen_string_literal: true

class AddGithubIdToUsersTable < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :github_id, :integer
    add_index :users, :github_id
  end

  def self.down
    remove_index :users, :github_id
    remove_column :users, :github_id
  end
end
