class UpdateBroadcastsMessageLimit < ActiveRecord::Migration[7.0]
  def change
    change_column :broadcasts, :message, :string, limit: 500
  end
end
