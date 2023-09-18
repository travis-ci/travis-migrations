# frozen_string_literal: true

class JobsAddRestartedAt < ActiveRecord::Migration[4.2]
  def change
    change_table :jobs do |t|
      t.datetime :restarted_at
    end
  end
end
