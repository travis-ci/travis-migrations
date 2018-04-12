class AddGithubScopesToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :github_scopes, :text
  end
end
