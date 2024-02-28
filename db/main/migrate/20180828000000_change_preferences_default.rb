# frozen_string_literal: true

class ChangePreferencesDefault < ActiveRecord::Migration[4.2]
  def up
    change_column_default :users, :preferences, {}
  end

  def down
    change_column_default :users, :preferences, nil
  end
end
