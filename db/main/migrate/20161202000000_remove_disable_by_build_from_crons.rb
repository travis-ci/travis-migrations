# This is an irreversible migration
class RemoveDisableByBuildFromCrons < ActiveRecord::Migration
  def up
    remove_column :crons, :disable_by_build
  end
end
