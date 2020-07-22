class AddFunctionMostRecentJobIdsForRepositoryByState < ActiveRecord::Migration[5.2]
    def up
      execute """
      CREATE OR REPLACE FUNCTION
        most_recent_job_ids_for_repository_by_state(rid int, st varchar) RETURNS table (job_id bigint, repository_id int) AS
        $BODY$
      DECLARE
      BEGIN
        RETURN QUERY select j.id, j.repository_id from jobs j where j.repository_id = rid and j.state = st order by j.id desc limit 100;
      END
      $BODY$
      LANGUAGE plpgsql;
      """
    end
  
    def down
      execute "DROP FUNCTION most_recent_job_ids_for_repository_by_state(integer, varchar)"
    end
end