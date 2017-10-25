class AddUpdatedAtTriggerToBuildsAndJobs < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE FUNCTION set_updated_at() RETURNS trigger AS $$
      BEGIN
        IF TG_OP = 'INSERT' OR
             (TG_OP = 'UPDATE' AND NEW.* IS DISTINCT FROM OLD.*) THEN
          NEW.updated_at := now();
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER set_updated_at_on_builds_update
      BEFORE UPDATE ON builds
      FOR EACH ROW
      WHEN (OLD.updated_at = NEW.updated_at)
      EXECUTE PROCEDURE set_updated_at();

      CREATE TRIGGER set_updated_at_on_builds_insert
      BEFORE INSERT on builds
      FOR EACH ROW
      WHEN (NEW.updated_at IS NULL)
      EXECUTE PROCEDURE set_updated_at();

      CREATE TRIGGER set_updated_at_on_jobs_update
      BEFORE UPDATE ON jobs
      FOR EACH ROW
      WHEN (OLD.updated_at = NEW.updated_at)
      EXECUTE PROCEDURE set_updated_at();

      CREATE TRIGGER set_updated_at_on_jobs_insert
      BEFORE INSERT on jobs
      FOR EACH ROW
      WHEN (NEW.updated_at IS NULL)
      EXECUTE PROCEDURE set_updated_at();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS set_updated_at_on_builds_update on builds;
      DROP TRIGGER IF EXISTS set_updated_at_on_builds_insert on builds;

      DROP TRIGGER IF EXISTS set_updated_at_on_jobs_update on jobs;
      DROP TRIGGER IF EXISTS set_updated_at_on_jobs_insert on jobs;

      DROP FUNCTION IF EXISTS set_updated_at();
    SQL
  end
end

