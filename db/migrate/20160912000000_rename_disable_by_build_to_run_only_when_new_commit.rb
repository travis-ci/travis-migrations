class RenameDisableByBuildToRunOnlyWhenNewCommit < ActiveRecord::Migration
  def up
    rename_column :crons, :disable_by_build, :run_only_when_new_commit
  end
end
