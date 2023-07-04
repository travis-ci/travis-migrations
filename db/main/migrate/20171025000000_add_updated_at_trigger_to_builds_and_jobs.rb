class AddUpdatedAtTriggerToBuildsAndJobs < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE FUNCTION set_updated_at() RETURNS trigger AS $$
      BEGIN
        IF TG_OP = 'INSERT' OR
             (TG_OP = 'UPDATE' AND NEW.* IS DISTINCT FROM OLD.*) THEN
          NEW.updated_at := statement_timestamp();
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER set_updated_at_on_builds
      BEFORE INSERT OR UPDATE ON builds
      FOR EACH ROW
      EXECUTE PROCEDURE set_updated_at();

      CREATE TRIGGER set_updated_at_on_jobs
      BEFORE INSERT OR UPDATE ON jobs
      FOR EACH ROW
      EXECUTE PROCEDURE set_updated_at();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS set_updated_at_on_builds on builds;
      DROP TRIGGER IF EXISTS set_updated_at_on_jobs on jobs;

      DROP FUNCTION IF EXISTS set_updated_at();
    SQL
  end
end
