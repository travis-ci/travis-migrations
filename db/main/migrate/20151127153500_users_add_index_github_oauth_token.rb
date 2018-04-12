class UsersAddIndexGithubOauthToken < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_users_on_github_oauth_token ON users (github_oauth_token)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_users_on_github_oauth_token"
  end
end
