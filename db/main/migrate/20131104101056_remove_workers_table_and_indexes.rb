# frozen_string_literal: true

class RemoveWorkersTableAndIndexes < ActiveRecord::Migration[4.2]
  def up
    drop_table :workers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
