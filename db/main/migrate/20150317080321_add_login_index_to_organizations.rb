# frozen_string_literal: true

class AddLoginIndexToOrganizations < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX IF EXISTS index_organizations_on_login'
    execute 'CREATE INDEX CONCURRENTLY index_organizations_on_login ON organizations(login)'
  end

  def down
    execute 'DROP INDEX IF EXISTS index_organizations_on_login'
  end
end
