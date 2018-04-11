class AddPullRequestNumberToBuilds < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :pull_request_number, :integer
  end
end
