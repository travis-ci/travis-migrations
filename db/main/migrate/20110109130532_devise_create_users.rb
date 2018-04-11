class DeviseCreateUsers < ActiveRecord::Migration[4.2]
  def self.up
    create_table(:users) do |t|
      t.string :name
      t.string :login
      t.string :email
      t.timestamps null: false
    end

    add_index :users, :login, :unique => true
  end

  def self.down
    drop_table :users
  end
end
