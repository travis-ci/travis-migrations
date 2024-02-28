# frozen_string_literal: true

class TasksAddTags < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tasks, :tags, :text
  end

  def self.down
    remove_column :tasks, :tags
  end
end
