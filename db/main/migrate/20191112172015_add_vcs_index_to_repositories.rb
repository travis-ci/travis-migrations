class AddVcsIndexToRepositories < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :repositories, [:vcs_type, :vcs_id], algorithm: :concurrently
  end
end
