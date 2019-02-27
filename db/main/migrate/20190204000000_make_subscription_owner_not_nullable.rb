class MakeSubscriptionOwnerNotNullable < ActiveRecord::Migration[4.2]
  def change
    change_column_null :subscriptions, :owner_type, false
    change_column_null :subscriptions, :owner_id, false
  end
end
