# frozen_string_literal: true

class JobsAddPrivate < ActiveRecord::Migration[4.2]
  def up
    change_table :jobs do |t|
      t.boolean :private
    end
  end

  def down
    remove_column :jobs, :private
  end
end
