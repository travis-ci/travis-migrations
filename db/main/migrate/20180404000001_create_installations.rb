class CreateInstallations < ActiveRecord::Migration[4.2]
  def change
    create_table    :installations do |t|
      t.integer     :github_id
      t.column      :permissions, json_type
      t.belongs_to  :owner, polymorphic: true, index: true
      t.belongs_to  :added_by, :removed_by
      t.foreign_key :users, column: :added_by_id
      t.foreign_key :users, column: :removed_by_id
      t.timestamps
    end

    change_table    :repositories do |t|
      t.boolean     :active_on_org
      t.timestamp   :managed_by_installation_at
    end
  end

  def json_type
    postgres_version == '9.3' ? :json : :jsonb
  end

  def postgres_version
    full = ActiveRecord::Base.connection.select_value('SELECT version()')
    full[/^PostgreSQL (\d+\.\d+)/, 1]
  end
end
