# frozen_string_literal: true

class UpdateFinishedBuilds < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE builds SET state = 'passed' WHERE state = 'finished' AND result = 0"
    execute "UPDATE builds SET state = 'failed' WHERE state = 'finished' AND result = 1"
    execute "UPDATE builds SET state = 'errored' WHERE state = 'finished' AND result IS NULL"
    count = execute("SELECT COUNT(*) FROM builds WHERE state = 'finished'").first['count'].to_i
    raise 'Finished builds remaining' unless count.zero?
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
