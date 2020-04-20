class AddFunctionMostRecentJobIdsForUserRepositoriesByStates < ActiveRecord::Migration[5.2]
  def up
    execute """
    CREATE OR REPLACE FUNCTION
      most_recent_job_ids_for_user_repositories_by_states(uid int, states varchar default '') RETURNS table (id bigint) AS
      $BODY$
    DECLARE
    rid int;
    BEGIN
      SET LOCAL work_mem = '16MB';
      IF states <> '' THEN
        RETURN QUERY WITH matrix AS (
          SELECT repository_id, replace(replace(job_state::varchar, '(', ''), ')', '') as job_state
          FROM permissions p
          CROSS JOIN (
            SELECT unnest(regexp_split_to_array(states, ','))
          ) AS job_state
          WHERE p.user_id = uid
        )
        SELECT recent.id
        FROM matrix m
        CROSS JOIN LATERAL (
          SELECT job_id AS id, repository_id
          FROM most_recent_job_ids_for_repository_by_state(m.repository_id, m.job_state::varchar)
        ) AS recent
        ORDER BY id desc;
      ELSE
        for rid in
          SELECT repository_id
          FROM permissions
          WHERE user_id = uid
          LOOP
            RETURN QUERY select j.id from jobs j where repository_id = rid order by j.id desc limit 100;
          END LOOP;
      END IF;
    END
    $BODY$
    LANGUAGE plpgsql;
    """
  end

  def down
    execute "DROP FUNCTION most_recent_job_ids_for_user_repositories_by_states(integer, varchar)"
  end
end
