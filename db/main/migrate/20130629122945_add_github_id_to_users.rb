# frozen_string_literal: true

class AddGithubIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :github_id, :integer

    add_index :repositories, :github_id
  end
end
