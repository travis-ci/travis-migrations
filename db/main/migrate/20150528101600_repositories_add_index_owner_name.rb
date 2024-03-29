# frozen_string_literal: true

class RepositoriesAddIndexOwnerName < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_repositories_on_owner_name ON repositories(owner_name)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_repositories_on_owner_name'
  end
end
