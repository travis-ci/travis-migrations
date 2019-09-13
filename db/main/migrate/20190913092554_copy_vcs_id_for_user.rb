class CopyVcsIdForUser < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    execute(%Q[UPDATE "users" SET vcs_id = github_id])
  end
end
