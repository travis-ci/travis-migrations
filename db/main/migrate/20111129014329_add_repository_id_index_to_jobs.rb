# frozen_string_literal: true

class AddRepositoryIdIndexToJobs < ActiveRecord::Migration[4.2]
  def self.up
    add_index(:jobs, :repository_id)
  end

  def self.down
    remove_index(:jobs, :repository_id)
  end
end
