class WorkersAddPayloadAndLastError < ActiveRecord::Migration[4.2]
  def change
    change_table :workers do |t|
      t.text :payload
      t.text :last_error
    end
  end
end
