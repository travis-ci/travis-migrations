class AddContactIdToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    change_table :subscriptions do |t|
      t.belongs_to :contact
    end
  end
end
