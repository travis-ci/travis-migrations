# frozen_string_literal: true

class AddGithubOauthTokenToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :github_oauth_token, :string
    add_index  :users, :github_oauth_token
  end

  def self.down
    remove_index  :users, :github_oauth_token
    remove_column :users, :github_oauth_token
  end
end
