class RequestsDropPayload < ActiveRecord::Migration[4.2]
  def change
    remove_column :requests, :payload, :text
  end
end
