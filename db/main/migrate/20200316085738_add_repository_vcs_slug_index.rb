class AddRepositoryVcsSlugIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_repositories_on_lower_vcs_slug ON repositories (LOWER(vcs_slug))'
    execute 'CREATE INDEX CONCURRENTLY index_repositories_on_lower_vcs_slug_valid ON repositories (LOWER(vcs_slug)) WHERE invalidated_at IS NULL'
  end
end
