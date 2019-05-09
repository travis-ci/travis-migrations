class IndexReposOnLowerSlug < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX index_repositories_on_lower_slug ON public.repositories USING gin ((((lower((owner_name)::text) || '/'::text) || lower((name)::text))) public.gin_trgm_ops);"
    execute "CREATE INDEX index_repositories_on_lower_owner_name ON public.repositories USING btree (lower((owner_name)::text));"
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_repositories_on_lower_slug'
    execute 'DROP INDEX CONCURRENTLY index_repositories_on_lower_owner_name'
  end
end
