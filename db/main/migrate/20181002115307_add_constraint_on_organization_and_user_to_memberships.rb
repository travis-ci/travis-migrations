class AddConstraintOnOrganizationAndUserToMemberships < ActiveRecord::Migration[4.2]
  def up
    execute <<~sql
DELETE FROM memberships WHERE id in (
	SELECT a.id FROM
		(SELECT m.id, row_number() OVER (ORDER BY m.id) as rnum
     FROM (SELECT user_id, organization_id
           FROM memberships
           GROUP BY (user_id, organization_id)
           HAVING count(*) > 1) t
           INNER JOIN memberships m ON m.user_id = t.user_id AND m.organization_id = t.organization_id) AS a
  WHERE mod(a.rnum, 2) = 0);

CREATE UNIQUE INDEX CONCURRENTLY index_organization_id_and_user_id_on_memberships ON memberships USING btree (organization_id, user_id);
    sql
  end

  def down
    execute <<~sql
DROP INDEX CONCURRENTLY index_organization_id_and_user_id_on_memberships;
		sql
  end
end
