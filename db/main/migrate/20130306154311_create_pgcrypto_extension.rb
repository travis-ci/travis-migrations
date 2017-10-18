class CreatePgcryptoExtension < ActiveRecord::Migration
  def up
    execute "create extension if not exists pgcrypto"
  end

  def down
    execute "drop extension pgcrypto"
  end
end
