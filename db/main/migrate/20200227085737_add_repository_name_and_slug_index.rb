class AddRepositoryNameAndSlugIndex < ActiveRecord::Migration
    disable_ddl_transaction!
  
    def up
      execute "CREATE INDEX CONCURRENTLY index_repositories_on_slug_or_names ON repositories (vcs_slug, owner_name, name) WHERE invalidated_at IS NULL"
    end

    def down
        execute 'DROP INDEX CONCURRENTLY IF EXISTS index_repositories_on_slug_or_names'
      end
  end