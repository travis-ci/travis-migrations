class RepositoriesAddLastBuildState < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :last_build_state, :string
  end
end
