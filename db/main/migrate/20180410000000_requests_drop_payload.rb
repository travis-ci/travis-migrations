class RequestsDropPayload < ActiveRecord::Migration
  def change
    remove_column :requests, :payload, :text
  end
end
