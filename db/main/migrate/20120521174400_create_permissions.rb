class CreatePermissions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :permissions do |t|
      t.belongs_to :user
      t.belongs_to :repository
      t.boolean :admin
    end

    add_index :permissions, :user_id
    add_index :permissions, :repository_id
  end

  def self.down
    drop_table :permissions
  end
end
