# frozen_string_literal: true

class DropFkRepositoriesCurrentBuildId < ActiveRecord::Migration[4.2]
  def up
    execute 'ALTER TABLE repositories DROP CONSTRAINT fk_repositories_current_build_id'
  end

  def down
    execute 'ALTER TABLE repositories ADD CONSTRAINT fk_repositories_current_build_id FOREIGN KEY (current_build_id) REFERENCES builds (id)'
  end
end
