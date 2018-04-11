class AddCachedMatrixIdsToBuilds < ActiveRecord::Migration[4.2]
  def up
   execute "ALTER TABLE builds ADD COLUMN cached_matrix_ids integer[]"
  end

  def down
   execute "ALTER TABLE builds DROP COLUMN cached_matrix_ids"
  end
end
