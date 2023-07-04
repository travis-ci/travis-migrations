class DropJobsConfig < ActiveRecord::Migration[4.2]
  def up
    remove_column :jobs, :config unless ENV['TRAVIS_ENTERPRISE']
  end

  def down; end
end
