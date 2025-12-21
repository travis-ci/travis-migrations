class AddIdxBuildsRepoCreatedConfig < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :builds, %i[repository_id created_at config_id],
              algorithm: :concurrently,
              name: 'idx_builds_repo_created_config',
              if_not_exists: true
  end

  def down
    remove_index :builds, name: 'idx_builds_repo_created_config', if_exists: true
  end
end
