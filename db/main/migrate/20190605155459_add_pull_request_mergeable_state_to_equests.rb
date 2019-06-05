class AddPullRequestMergeableStateToEquests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :pull_request_mergeable_state, :string
  end
end
