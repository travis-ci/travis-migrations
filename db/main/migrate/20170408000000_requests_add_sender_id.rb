class RequestsAddSenderId < ActiveRecord::Migration
  def change
    change_table :requests do |t|
      t.belongs_to :sender, polymorphic: true
    end
  end
end
