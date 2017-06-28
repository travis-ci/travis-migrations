class OwnerGroupsIndexOwnerIdOwnerType < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_owner_groups_on_owner_type_and_owner_id ON owner_groups (owner_type, owner_id);"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_owner_groups_on_owner_type_and_owner_id"
  end
end
