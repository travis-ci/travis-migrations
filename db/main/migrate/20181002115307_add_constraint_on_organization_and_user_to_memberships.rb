# frozen_string_literal: true

class AddConstraintOnOrganizationAndUserToMemberships < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute <<~SQL
      CREATE UNIQUE INDEX CONCURRENTLY index_organization_id_and_user_id_on_memberships ON memberships USING btree (organization_id, user_id);
    SQL
  end

  def down
    execute <<~SQL
      DROP INDEX CONCURRENTLY index_organization_id_and_user_id_on_memberships;
    SQL
  end
end
