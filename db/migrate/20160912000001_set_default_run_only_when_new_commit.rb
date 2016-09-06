class SetDefaultRunOnlyWhenNewCommit < ActiveRecord::Migration
  def change
    change_column :crons, :run_only_when_new_commit, :boolean, :default => false
  end
end
