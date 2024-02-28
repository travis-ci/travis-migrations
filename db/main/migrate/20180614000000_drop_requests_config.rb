# frozen_string_literal: true

class DropRequestsConfig < ActiveRecord::Migration[4.2]
  def up
    remove_column :requests, :config unless ENV['TRAVIS_ENTERPRISE']
  end

  def down; end
end
