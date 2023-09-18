# frozen_string_literal: true

class BuildsAddIndexOnFinishedAt < ActiveRecord::Migration[4.2]
  def change
    add_index 'builds', 'finished_at'
  end
end
