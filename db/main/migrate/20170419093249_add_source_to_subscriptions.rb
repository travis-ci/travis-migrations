class AddSourceToSubscriptions < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE TYPE source_type AS ENUM ('manual', 'stripe', 'github', 'unknown');
    SQL
    add_column :subscriptions, :source, :source_type, default: 'unknown', null: false
  end

  def down
    execute <<-SQL
      ALTER TABLE subscriptions DROP COLUMN source;
      DROP TYPE source_type;
    SQL
  end
end
