class AddCurrentBuildIdToRepositories < ActiveRecord::Migration[4.2]
  def up
    add_column :repositories, :current_build_id, :bigint
    execute 'ALTER TABLE repositories ADD CONSTRAINT fk_repositories_current_build_id FOREIGN KEY (current_build_id) REFERENCES builds (id);'
  end

  def down
    remove_column :repositories, :current_build_id
  end
end
