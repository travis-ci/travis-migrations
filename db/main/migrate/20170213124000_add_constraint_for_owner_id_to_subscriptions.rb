class AddConstraintForOwnerIdToSubscriptions < ActiveRecord::Migration[4.2]
  def up
    execute "CREATE UNIQUE INDEX subscriptions_owner ON subscriptions (owner_id, owner_type) WHERE (status = 'subscribed');"
  rescue => e
    puts e.message
  end

end
