module Travis
  # convenience method to check the Postgres version we're running against and do some things differently. Include in the migration class to call them
  module PostgresVersion
    def json_type
      postgres_version == '9.3' ? :json : :jsonb
    end

    def postgres_version
      full = ActiveRecord::Base.connection.select_value('SELECT version()')
      full[/^PostgreSQL (\d+\.\d+)/, 1]
    end
  end
end
