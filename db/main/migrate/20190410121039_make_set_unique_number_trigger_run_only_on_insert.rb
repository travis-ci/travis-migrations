class MakeSetUniqueNumberTriggerRunOnlyOnInsert < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      DROP TRIGGER set_unique_number_on_builds ON builds;
      CREATE TRIGGER set_unique_number_on_builds
      BEFORE INSERT ON builds
      FOR EACH ROW
      EXECUTE PROCEDURE set_unique_number();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER set_unique_number_on_builds ON builds;
      CREATE TRIGGER set_unique_number_on_builds
      BEFORE INSERT OR UPDATE ON builds
      FOR EACH ROW
      EXECUTE PROCEDURE set_unique_number();
    SQL
  end
end
