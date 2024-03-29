# frozen_string_literal: true

class AddIndexOnGithubIdToOrganizations < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_organizations_on_github_id ON organizations(github_id)'
  end

  def down
    execute 'DROP INDEX index_organizations_on_github_id'
  end
end
