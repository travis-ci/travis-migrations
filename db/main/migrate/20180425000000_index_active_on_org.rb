class IndexActiveOnOrg < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_active_on_org ON repositories (active_on_org)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_active_on_org"
  end
end