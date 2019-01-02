require 'rails'
require 'active_record/railtie'
require 'travis/postgres_version'

app = Class.new(Rails::Application)
app.config.active_support.deprecation = :log
app.load_tasks

Rake::Task['environment'].enhance do
  app.initialize!
end

%w(about log:clear middleware notes notes:custom routes secret stats time:zones:all tmp:clear tmp:create).each do |task|
  Rake::Task[task].clear
end

module Travis
  module Migrations
    class << self

    end
  end
end
