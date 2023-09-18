# frozen_string_literal: true

class CommitsAddIndexOnBranch < ActiveRecord::Migration[4.2]
  def change
    add_index 'commits', 'branch'
  end
end
