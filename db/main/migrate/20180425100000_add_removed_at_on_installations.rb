# frozen_string_literal: true

class AddRemovedAtOnInstallations < ActiveRecord::Migration[4.2]
  def change
    add_column :installations, :removed_at, :datetime
  end
end
