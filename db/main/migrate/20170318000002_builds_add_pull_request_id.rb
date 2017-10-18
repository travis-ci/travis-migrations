class BuildsAddPullRequestId < ActiveRecord::Migration
  def change
    change_table :builds do |t|
      t.integer :pull_request_id
    end
  end
end
