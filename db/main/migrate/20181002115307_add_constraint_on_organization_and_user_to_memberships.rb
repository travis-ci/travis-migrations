class AddConstraintOnOrganizationAndUserToMemberships < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute <<~sql
CREATE UNIQUE INDEX CONCURRENTLY index_organization_id_and_user_id_on_memberships ON memberships USING btree (organization_id, user_id);
    sql
  end

  def down
    execute <<~sql
DROP INDEX CONCURRENTLY index_organization_id_and_user_id_on_memberships;
		sql
  end
end
