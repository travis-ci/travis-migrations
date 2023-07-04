# frozen_string_literal: true

class AddAvatarUrlToUsers < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :avatar_url, :string
  end

  def down
    remove_column :users, :avatar_url
  end
end
