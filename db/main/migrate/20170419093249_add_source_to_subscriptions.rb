class AddSourceToSubscriptions < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE source_type AS ENUM ('manual', 'stripe', 'github');
    SQL
    add_column :subscriptions, :source, :source_type, default: 'manual', null: false
  end

  def down
    execute <<-SQL
      DROP TYPE source_type;
    SQL
    drop_column :source
  end
end
