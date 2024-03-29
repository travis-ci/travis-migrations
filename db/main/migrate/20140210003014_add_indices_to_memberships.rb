# frozen_string_literal: true

class AddIndicesToMemberships < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_memberships_on_user_id ON memberships(user_id)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_memberships_on_user_id'
  end
end
