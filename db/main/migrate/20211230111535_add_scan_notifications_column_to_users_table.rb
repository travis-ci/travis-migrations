class AddScanNotificationsColumnToUsersTable < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :scan_notifications, :boolean, default: false
  end
end
