class CreateInstallations < ActiveRecord::Migration
  PSQL = ActiveRecord::Base.connection.select_value('SELECT version()')

  def self.up
    create_table :installations do |t|
      t.belongs_to :owner, :polymorphic => true # will add owner_id and owner_type columns
      t.integer    :github_id
      if /PostgreSQL 9.3/.match(PSQL)
        t.json       :permissions
      else
        t.jsonb    :permissions
      end
      t.integer    :added_by
      t.integer    :removed_by
      t.datetime   :removed_on
      t.datetime   :updated_on
      t.index      ([:owner_id, :owner_type])
      t.index      :owner_id
    end
  end

  def self.down
    drop_table :installations
  end
end