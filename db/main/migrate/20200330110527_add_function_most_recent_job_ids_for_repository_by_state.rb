class AddFunctionMostRecentJobIdsForRepositoryByState < ActiveRecord::Migration[5.2]
  def up
    execute """
    CREATE OR REPLACE FUNCTION
      most_recent_job_ids_for_repository_by_state(repository_id int, states varchar) RETURNS table (id int) AS
      $BODY$
    DECLARE
    BEGIN
      RETURN QUERY EXECUTE format(
        'SELECT j.id from jobs j where repository_id = %s and state = any(''{%s}'') order by id desc limit 100',
        repository_id,
        states
      );
    END
    $BODY$
    LANGUAGE plpgsql;
    """
  end

  def down
    execute "DROP FUNCTION most_recent_job_ids_for_repository_by_state(integer, varchar)"
  end
end
