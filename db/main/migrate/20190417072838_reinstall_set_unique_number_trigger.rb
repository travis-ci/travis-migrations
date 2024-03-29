# frozen_string_literal: true

class ReinstallSetUniqueNumberTrigger < ActiveRecord::Migration[5.2]
  def up
    execute File.read(Rails.root.join('db/main/sql/triggers/drop_set_unique_number.sql'))
    execute File.read(Rails.root.join('db/main/sql/triggers/create_set_unique_number.sql'))
  end

  def down; end
end
