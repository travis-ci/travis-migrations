class AddFunctionMostRecentNonQueuedJobIdsForUserRepositories < ActiveRecord::Migration[5.2]
  def up
    execute """
      CREATE OR REPLACE FUNCTION
        most_recent_non_queued_job_ids_for_user_repositories(uid int, lim int default 100) RETURNS table (id bigint) AS
        $BODY$
      DECLARE
      rid record;
      BEGIN
        for rid in
          SELECT repository_id
          FROM permissions
          WHERE user_id = uid
          LOOP
            RETURN QUERY EXECUTE
            'SELECT id from jobs where repository_id = ' || rid || ' and state = any (''{passed,started,errored,failed,canceled}''::varchar[]) order by id desc limit ' || lim;
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
