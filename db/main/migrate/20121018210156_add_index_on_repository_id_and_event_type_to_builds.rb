class AddIndexOnRepositoryIdAndEventTypeToBuilds < ActiveRecord::Migration[4.2]
  def change
    add_index :builds, [:repository_id, :event_type]
  end
end
