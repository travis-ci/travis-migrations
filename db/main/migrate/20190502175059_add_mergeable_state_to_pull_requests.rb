# frozen_string_literal: true

class AddMergeableStateToPullRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :pull_requests, :mergeable_state, :string
  end
end
