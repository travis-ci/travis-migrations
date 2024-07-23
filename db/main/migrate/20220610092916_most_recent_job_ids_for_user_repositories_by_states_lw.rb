class MostRecentJobIdsForUserRepositoriesByStatesLw < ActiveRecord::Migration[5.2]
  def up
    execute """
    CREATE OR REPLACE FUNCTION
      most_recent_job_ids_for_user_repositories_by_states_lw(uid int, states varchar default '') RETURNS table (id bigint)
      LANGUAGE plpgsql
      AS $$
      DECLARE
      rid int;
        BEGIN
          SET LOCAL work_mem = '16MB';
          IF states <> '' THEN
            for rid in
              SELECT repository_id
              FROM permissions
              WHERE user_id = uid
              LOOP
                RETURN QUERY select j.id from jobs j where repository_id = rid and state in (SELECT unnest(regexp_split_to_array(states, ','))) order by j.id desc limit 100;
              END LOOP;
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
    $$;
    """
  end

  def down
    execute "DROP FUNCTION most_recent_job_ids_for_user_repositories_by_states_lw(integer, varchar)"
  end
end
