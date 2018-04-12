class RequestsAddPullRequestId < ActiveRecord::Migration[4.2]
  def change
    change_table :requests do |t|
      t.integer :pull_request_id
    end
  end
end
