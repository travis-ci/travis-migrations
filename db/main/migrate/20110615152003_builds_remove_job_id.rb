# frozen_string_literal: true

class BuildsRemoveJobId < ActiveRecord::Migration[4.2]
  def self.up
    change_table :builds do |t|
      t.remove :job_id
    end
  end

  def self.down
    change_table :builds do |t|
      t.string :job_id
    end
  end
end
