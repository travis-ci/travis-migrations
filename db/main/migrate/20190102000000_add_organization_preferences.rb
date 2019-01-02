class AddOrganizationPreferences < ActiveRecord::Migration[5.2]
  def change
    change_table :organizations do |t|
      t.column :preferences, json_type
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
