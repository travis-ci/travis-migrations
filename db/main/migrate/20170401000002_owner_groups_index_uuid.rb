# frozen_string_literal: true

class OwnerGroupsIndexUuid < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_owner_groups_on_uuid ON owner_groups (uuid);'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_owner_groups_on_uuid'
  end
end
