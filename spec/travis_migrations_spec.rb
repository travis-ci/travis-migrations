require 'spec_helper'
require 'yaml'

describe "Travis Migrations Custom Rake Tasks" do
  it "setups the database with the correct tables" do
    dbconfig = YAML.load(ERB.new(File.read('config/database.yml')).result)
    ActiveRecord::Base.establish_connection dbconfig['test']
    ActiveRecord::Base.connection_pool.with_connection do |connection|

      tables = connection.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';").field_values('table_name')

      ["schema_migrations", "tokens", "users", "builds", "repositories",
        "commits", "requests", "ssl_keys", "memberships", "urls",
        "permissions", "jobs", "broadcasts", "emails", "logs", "log_parts",
        "organizations", "annotation_providers", "annotations", "branches",
        "stars", "crons", "subscriptions", "plans", "coupons", "stripe_events", "invoices"].each do |table_name|
        expect(tables).to include(table_name)
      end
    end
  end
end
