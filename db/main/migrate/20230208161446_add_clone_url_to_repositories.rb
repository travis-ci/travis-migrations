# frozen_string_literal: true

class AddCloneUrlToRepositories < ActiveRecord::Migration[5.2]
  def change
    add_column :repositories, :clone_url, :string
  end
end
