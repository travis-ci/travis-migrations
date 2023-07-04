class AddPreviousStatesTriggers < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE FUNCTION save_state_change() RETURNS trigger AS $$
      DECLARE
        previous_job_state_id BIGINT;
      BEGIN
        if TG_OP='UPDATE' then
          UPDATE previous_job_states SET ended_at = NOW() WHERE id = OLD.previous_job_state_id;
        end if;

        INSERT INTO previous_job_states (job_id, set_at, state) VALUES(NEW.id, NOW(), NEW.state)
          RETURNING id INTO previous_job_state_id;
        NEW.previous_job_state_id = previous_job_state_id;

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
