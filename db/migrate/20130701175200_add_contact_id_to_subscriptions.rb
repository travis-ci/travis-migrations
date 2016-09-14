class AddContactIdToSubscriptions < ActiveRecord::Migration
  def change
    change_table :subscriptions do |t|
      t.belongs_to :contact
    end
  end
end
