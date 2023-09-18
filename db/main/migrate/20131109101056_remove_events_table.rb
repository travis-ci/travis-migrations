# frozen_string_literal: true

class RemoveEventsTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :events
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
