class UsersAddFirstLoggedInAt < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :first_logged_in_at, :datetime
  end
end
