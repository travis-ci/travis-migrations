# frozen_string_literal: true

class RequestsAddPrivate < ActiveRecord::Migration[4.2]
  def up
    change_table :requests do |t|
      t.boolean :private
    end
  end

  def down
    remove_column :requests, :private
  end
end
