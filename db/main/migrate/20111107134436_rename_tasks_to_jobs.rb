# frozen_string_literal: true

class RenameTasksToJobs < ActiveRecord::Migration[4.2]
  def up
    rename_table :tasks, :jobs

    execute "UPDATE jobs SET type = 'Job::Test' WHERE type = 'Task::Test'"
    execute "UPDATE jobs SET type = 'Job::Configure' WHERE type = 'Task::Configure'"
  end

  def down
    begin
      rename_table :jobs, :tasks
    rescue StandardError
      nil
    end

    execute "UPDATE tasks SET type = 'Task::Test' WHERE type = 'Job::Test'"
    execute "UPDATE tasks SET type = 'Task::Configure' WHERE type = 'Job::Configure'"
  end
end
