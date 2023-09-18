# frozen_string_literal: true

# This is an irreversible migration
class RemoveDisableByBuildFromCrons < ActiveRecord::Migration[4.2]
  def up
    remove_column :crons, :disable_by_build
  end
end
