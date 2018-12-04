DROP TRIGGER IF EXISTS set_unique_name_on_branches ON branches;
DROP FUNCTION IF EXISTS set_unique_name();
CREATE FUNCTION set_unique_name() RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    NEW.unique_name := NEW.name;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_unique_name_on_branches
BEFORE INSERT OR UPDATE ON branches
FOR EACH ROW
EXECUTE PROCEDURE set_unique_name();
