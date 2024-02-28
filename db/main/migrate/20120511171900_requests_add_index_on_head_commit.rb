# frozen_string_literal: true

class RequestsAddIndexOnHeadCommit < ActiveRecord::Migration[4.2]
  def self.up
    add_index :requests, :head_commit
  end

  def self.down
    remove_index :requests, :head_commit
  end
end
