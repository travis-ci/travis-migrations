# frozen_string_literal: true

class BuildsAddRestartedAt < ActiveRecord::Migration[4.2]
  def change
    change_table :builds do |t|
      t.datetime :restarted_at
    end
  end
end
