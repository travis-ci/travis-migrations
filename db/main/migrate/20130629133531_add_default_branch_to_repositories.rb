# frozen_string_literal: true

class AddDefaultBranchToRepositories < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :default_branch, :string
  end
end
