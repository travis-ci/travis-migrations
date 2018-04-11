class AddBuildsIndexOnRepositoryIdAndState < ActiveRecord::Migration[4.2]
  def change
    remove_index 'builds', :column => 'repository_id'
    add_index    'builds', ['repository_id', 'state']
  end
end
