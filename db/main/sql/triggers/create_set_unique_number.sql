DROP TRIGGER IF EXISTS set_unique_number_on_builds ON builds;
DROP FUNCTION IF EXISTS set_unique_number();
CREATE FUNCTION set_unique_number() RETURNS trigger AS $$
DECLARE
  disable boolean;
BEGIN
  disable := 'f';
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    BEGIN
       disable := current_setting('set_unique_number_on_builds.disable');
    EXCEPTION
    WHEN others THEN
      set set_unique_number_on_builds.disable = 'f';
    END;

    IF NOT disable THEN
      NEW.unique_number := NEW.number;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_unique_number_on_builds
BEFORE INSERT OR UPDATE ON builds
FOR EACH ROW
EXECUTE PROCEDURE set_unique_number();
