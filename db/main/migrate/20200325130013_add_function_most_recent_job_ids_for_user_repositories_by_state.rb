class AddFunctionMostRecentJobIdsForUserRepositoriesByState < ActiveRecord::Migration[5.2]
  def up
    execute """
    CREATE OR REPLACE FUNCTION
      most_recent_job_ids_for_user_repositories_by_state(uid int, states text[]) RETURNS table (id int) AS
      $BODY$
    DECLARE
    rid int;
    sanitized_states varchar;
    BEGIN
      sanitized_states := array_to_string(states, ',', '');
      for rid in
        SELECT repository_id
        FROM permissions
        WHERE user_id = uid
        LOOP
          RETURN QUERY select * from most_recent_job_ids_for_repository_by_state(rid, sanitized_states);
        END LOOP;
    END
    $BODY$
    LANGUAGE plpgsql;
    """
  end

  def down
    execute "DROP FUNCTION most_recent_non_queued_job_ids_for_user_repositories(integer, integer)"
  end
end
