# frozen_string_literal: true

class AddSettingsToRepositories < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :settings, :json
  end
end
