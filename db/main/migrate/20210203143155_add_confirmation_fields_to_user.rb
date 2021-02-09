class AddConfirmationFieldsToUser < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :confirmation_token, :string

    add_index :users, :confirmation_token
  end

  def down
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at
    remove_column :users, :confirmation_token
  end
end
