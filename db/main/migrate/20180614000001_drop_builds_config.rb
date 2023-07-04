class DropBuildsConfig < ActiveRecord::Migration[4.2]
  def up
    remove_column :builds, :config unless ENV['TRAVIS_ENTERPRISE']
  end

  def down; end
end
