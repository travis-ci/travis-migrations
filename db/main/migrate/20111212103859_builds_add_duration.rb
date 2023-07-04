# frozen_string_literal: true

class BuildsAddDuration < ActiveRecord::Migration[4.2]
  def up
    change_table :builds do |t|
      t.integer :duration
    end
  end

  def down
    remove_column :builds, :duration
  end
end
