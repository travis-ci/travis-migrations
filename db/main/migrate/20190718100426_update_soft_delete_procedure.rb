# frozen_string_literal: true

class UpdateSoftDeleteProcedure < ActiveRecord::Migration[5.2]
  def up
    execute File.read(Rails.root.join('db/main/sql/create_soft_delete_repo_data.sql'))
  end

  def down; end
end
