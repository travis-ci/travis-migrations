# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[4.2]
  def up
    create_table :memberships do |t|
      t.references :organization
      t.references :user
    end
  end

  def down
    drop_table :memberships
  end
end
