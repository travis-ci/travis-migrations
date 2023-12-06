class AddUniqueVcsIdTypeIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    remove_index :repositories, column: [:vcs_id, :vcs_type], algorithm: :concurrently
    add_index :repositories, [:vcs_id, :vcs_type], algorithm: :concurrently, unique: true
    remove_index :organizations, column: [:vcs_id, :vcs_type], algorithm: :concurrently
    add_index :organizations, [:vcs_id, :vcs_type], algorithm: :concurrently, unique: true
    remove_index :users, column: [:vcs_id, :vcs_type], algorithm: :concurrently
    add_index :users, [:vcs_id, :vcs_type], algorithm: :concurrently, unique: true
  end
end
