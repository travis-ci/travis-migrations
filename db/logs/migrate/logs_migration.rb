class LogsMigration <  ActiveRecord::Migration
  logs_db = defined?(Travis.config) ? Travis.config.logs_database : Rails.env
  ActiveRecord::Base.establish_connection(logs_db)
end
