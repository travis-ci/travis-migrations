class AddConstraintForOwnerIdToSubscriptions < ActiveRecord::Migration
  def up
    execute "ALTER TABLE subscriptions ADD CONSTRAINT subscriptions_owner_id UNIQUE (owner_id, owner_type);"
  end

end
