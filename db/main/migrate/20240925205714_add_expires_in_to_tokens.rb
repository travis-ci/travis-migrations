class AddExpiresInToTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :expires_in, :integer
  end
end
