# frozen_string_literal: true

class AddPullRequestTitleToBuilds < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :pull_request_title, :text
  end
end
