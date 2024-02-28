# frozen_string_literal: true

class JobsAddStageNumber < ActiveRecord::Migration[4.2]
  def change
    add_column :jobs, :stage_number, :string
  end
end
