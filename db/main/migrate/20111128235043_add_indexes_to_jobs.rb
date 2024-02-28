# frozen_string_literal: true

class AddIndexesToJobs < ActiveRecord::Migration[4.2]
  def self.up
    add_index(:jobs, %i[queue state])
  end

  def self.down
    remove_index(:jobs, column: %i[queue state])
  end
end
