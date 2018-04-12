class PullRequestsCreate < ActiveRecord::Migration[4.2]
  def change
    create_table :pull_requests do |t|
      t.belongs_to :repository
      t.integer :number
      t.string  :title
      t.string  :state
      t.integer :head_repo_github_id
      t.string  :head_repo_slug
      t.string  :head_ref
      t.timestamps
    end
  end
end
