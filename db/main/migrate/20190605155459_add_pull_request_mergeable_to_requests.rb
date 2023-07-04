# frozen_string_literal: true

class AddPullRequestMergeableToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :pull_request_mergeable, :string
  end
end
