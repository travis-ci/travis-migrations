# frozen_string_literal: true

class AddCanceledAtToJobsAndBuilds < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :canceled_at, :datetime
    add_column :jobs, :canceled_at, :datetime
  end
end
