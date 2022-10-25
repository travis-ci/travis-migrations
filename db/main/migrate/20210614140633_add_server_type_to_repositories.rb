class AddServerTypeToRepositories < ActiveRecord::Migration[5.2]
  def change
    add_column :repositories, :server_type, :string, limit: 20
  end
end
