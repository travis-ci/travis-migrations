# frozen_string_literal: true

class AddNextBuildNumberToRepository < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :next_build_number, :integer
  end
end
