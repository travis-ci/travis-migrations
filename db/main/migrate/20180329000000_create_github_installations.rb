class CreateGithubInstallations < ActiveRecord::Migration
  PSQL = ActiveRecord::Base.connection.select_value('SELECT version()')

  def self.up
    create_table :github_installations do |t|
      t.belongs_to :owner, :polymorphic => true
      t.integer    :github_installation_id
      if /PostgreSQL 9.3/.match(PSQL)
        t.json       :permissions
      else
        t.jsonb    :permissions
      end
      t.integer    :added_by
      t.integer    :removed_by
      t.datetime   :removed_on
      t.datetime   :updated_on
    end

    def change
      add_reference :github_installations, :added_by, foreign_key: { to_table: :users }
      add_reference :github_installations, :removed_by, foreign_key: { to_table: :users }
      add_column :repositories, :active_on_org, :boolean
      add_column :repositories, :activated_by_github_apps_on, :timestamp
    end
  end

  def self.down
    drop_table :github_installations
    remove_column :repositories, :active_on_org
    remove_column :repositories, :activated_by_github_apps_on
  end
end
