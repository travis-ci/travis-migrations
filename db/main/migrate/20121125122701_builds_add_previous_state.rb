# frozen_string_literal: true

class BuildsAddPreviousState < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :previous_state, :string
  end
end
