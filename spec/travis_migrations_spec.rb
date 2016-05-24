require 'spec_helper'
require 'yaml'

describe "Travis Migrations Custom Rake Tasks" do
  it "doesn't break on migrate (exits cleanly)" do
    expect(system('RAILS_ENV=test bundle exec rake db:create')).to be_truthy
    expect(system('RAILS_ENV=test bundle exec rake db:migrate')).to be_truthy
  end
  it "setups the database" do
    expect(system('RAILS_ENV=test bundle exec rake db:drop')).to be_truthy
    expect(system('RAILS_ENV=test bundle exec rake db:create')).to be_truthy
    expect(system('RAILS_ENV=test bundle exec rake db:migrate')).to be_truthy

    dbconfig = YAML.load(ERB.new(File.read('config/database.yml')).result)
    ActiveRecord::Base.establish_connection dbconfig['test']
    ActiveRecord::Base.connection_pool.with_connection do |connection|

      tables = connection.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';").field_values('table_name')

      ["schema_migrations", "tokens", "users", "builds", "repositories",
        "commits", "requests", "ssl_keys", "memberships", "urls",
        "permissions", "jobs", "broadcasts", "emails", "logs", "log_parts",
        "organizations", "annotation_providers", "annotations", "branches",
        "stars", "crons"].each do |table_name|
        expect(tables).to include(table_name)
      end
    end
  end
end
