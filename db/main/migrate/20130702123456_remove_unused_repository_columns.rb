class RemoveUnusedRepositoryColumns < ActiveRecord::Migration[4.2]
  def change
    remove_column :repositories, :last_duration
    remove_column :repositories, :last_build_status
    remove_column :repositories, :last_build_result
    remove_column :repositories, :last_build_language
  end
end
