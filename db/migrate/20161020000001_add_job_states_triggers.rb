class AddJobStatesTriggers < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE FUNCTION save_state_change() RETURNS trigger AS $$
      DECLARE
        job_state_id BIGINT;
      BEGIN
        if TG_OP='UPDATE' then
          UPDATE job_states SET ended_at = NOW() WHERE id = OLD.job_state_id;
        end if;

        INSERT INTO job_states (job_id, set_at, state) VALUES(NEW.id, NOW(), NEW.state)
          RETURNING id INTO job_state_id;
        NEW.job_state_id = job_state_id;

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER save_state_change_on_update
      BEFORE UPDATE on jobs
      FOR EACH ROW
      WHEN (OLD.state IS DISTINCT FROM NEW.state)
      EXECUTE PROCEDURE save_state_change();

      CREATE TRIGGER save_state_change_on_insert
      BEFORE INSERT on jobs
      FOR EACH ROW
      EXECUTE PROCEDURE save_state_change();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS save_state_change_on_update on jobs;
      DROP TRIGGER IF EXISTS save_state_change_on_insert on jobs;
      DROP FUNCTION IF EXISTS save_state_change();
    SQL
  end
end

