class UsersAddRedactedAt < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.datetime :redacted_at
    end
  end
end
