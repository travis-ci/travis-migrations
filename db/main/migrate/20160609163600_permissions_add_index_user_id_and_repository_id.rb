# frozen_string_literal: true

class PermissionsAddIndexUserIdAndRepositoryId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_permissions_on_user_id_and_repository_id ON permissions (user_id, repository_id)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_permissions_on_user_id_and_repository_id'
  end
end
