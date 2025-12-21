class AddIdxBuildBackupsRepoCreated < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :build_backups, %i[repository_id created_at],
              algorithm: :concurrently,
              name: 'idx_build_backups_repo_created',
              if_not_exists: true
  end

  def down
    remove_index :build_backups, name: 'idx_build_backups_repo_created', if_exists: true
  end
end
