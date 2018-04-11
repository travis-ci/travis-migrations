class AddGithubLanguageToRepositories < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :github_language, :string
  end
end
