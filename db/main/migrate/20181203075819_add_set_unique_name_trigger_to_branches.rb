# frozen_string_literal: true

class AddSetUniqueNameTriggerToBranches < ActiveRecord::Migration[5.2]
  def up
    execute File.read(Rails.root.join('db/main/sql/triggers/create_set_unique_name.sql'))
  end

  def down
    execute File.read(Rails.root.join('db/main/sql/triggers/drop_set_unique_name.sql'))
  end
end
