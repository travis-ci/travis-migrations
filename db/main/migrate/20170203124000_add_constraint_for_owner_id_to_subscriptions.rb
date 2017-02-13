class AddConstraintForOwnerIdToSubscriptions < ActiveRecord::Migration
  def up
    execute "CREATE UNIQUE INDEX subscriptions_owner ON subscriptions (owner_id, owner_type) WHERE (status = 'subscribed');"
  end

end
