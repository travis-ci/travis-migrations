# frozen_string_literal: true

class ChangeOrganizationPreferencesDefault < ActiveRecord::Migration[5.2]
  def up
    change_column_default :organizations, :preferences, {}
  end

  def down
    change_column_default :organizations, :preferences, nil
  end
end
