class AddSourceToSubscriptions < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE source_type AS ENUM ('manual', 'stripe', 'github', 'unknown');
    SQL
    add_column :subscriptions, :source, :source_type, default: 'unknown', null: false
  end

  def down
    execute <<-SQL
      DROP TYPE source_type;
    SQL
    drop_column :source
  end
end
