class MessagesAddTypeSourceLine < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :messages, :type, :string, default: nil
    add_column :messages, :src, :string, default: nil
    add_column :messages, :line, :integer, default: nil
  end

  def down
    remove_column :messages, :type
    remove_column :messages, :src
    remove_column :messages, :line
  end
end
