# frozen_string_literal: true

class StarsAddIndexUserIdAndRepositoryId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE UNIQUE INDEX index_stars_on_user_id_and_repository_id ON stars (user_id, repository_id)'
  end

  def down
    execute 'DROP INDEX index_stars_on_user_id_and_repository_id'
  end
end
