class RequestsAddResultAndMessage < ActiveRecord::Migration[4.2]
  def change
    add_column :requests, :result, :string
    add_column :requests, :message, :string
  end
end
