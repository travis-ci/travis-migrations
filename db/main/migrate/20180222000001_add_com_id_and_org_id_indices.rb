# frozen_string_literal: true

class AddComIdAndOrgIdIndices < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_branches_on_org_id ON branches USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_builds_on_org_id ON builds USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_jobs_on_org_id ON jobs USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_commits_on_org_id ON commits USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_crons_on_org_id ON crons USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_organizations_on_org_id ON organizations USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_permissions_on_org_id ON permissions USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_pull_requests_on_org_id ON pull_requests USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_repositories_on_org_id ON repositories USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_requests_on_org_id ON requests USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_ssl_keys_on_org_id ON ssl_keys USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_stages_on_org_id ON stages USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_tags_on_org_id ON tags USING btree (org_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_users_on_org_id ON users USING btree (org_id)'

    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_branches_on_com_id ON branches USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_builds_on_com_id ON builds USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_jobs_on_com_id ON jobs USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_commits_on_com_id ON commits USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_crons_on_com_id ON crons USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_organizations_on_com_id ON organizations USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_permissions_on_com_id ON permissions USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_pull_requests_on_com_id ON pull_requests USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_repositories_on_com_id ON repositories USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_requests_on_com_id ON requests USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_ssl_keys_on_com_id ON ssl_keys USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_stages_on_com_id ON stages USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_tags_on_com_id ON tags USING btree (com_id)'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_users_on_com_id ON users USING btree (com_id)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_branches_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_builds_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_jobs_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_commits_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_crons_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_organizations_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_permissions_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_pull_requests_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_repositories_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_requests_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_ssl_keys_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_stages_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_tags_on_org_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_users_on_org_id'

    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_branches_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_builds_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_jobs_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_commits_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_crons_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_organizations_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_permissions_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_pull_requests_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_repositories_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_requests_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_ssl_keys_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_stages_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_tags_on_com_id'
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_users_on_com_id'
  end
end
