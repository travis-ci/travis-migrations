class RequestsAddPullRequestId < ActiveRecord::Migration
  def change
    change_table :requests do |t|
      t.integer :pull_request_id
    end
  end
end
