# frozen_string_literal: true

class AddPullRequestFieldsToRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :requests, :event_type, :string
    add_column :requests, :comments_url, :string
    add_column :requests, :base_commit, :string
    add_column :requests, :head_commit, :string
  end
end
