# frozen_string_literal: true

class ReposAddFork < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :repositories, :fork, :boolean, default: nil
  end

  def down
    remove_column :repositories, :fork
  end
end
