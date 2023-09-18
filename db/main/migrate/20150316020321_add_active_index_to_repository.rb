# frozen_string_literal: true

class AddActiveIndexToRepository < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX IF EXISTS index_repositories_on_active'
    execute 'CREATE INDEX CONCURRENTLY index_repositories_on_active ON repositories(active)'
  end

  def down
    execute 'DROP INDEX IF EXISTS index_repositories_on_active'
  end
end
