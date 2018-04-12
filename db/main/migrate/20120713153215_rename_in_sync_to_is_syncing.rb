class RenameInSyncToIsSyncing < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :in_sync, :is_syncing
  end
end
