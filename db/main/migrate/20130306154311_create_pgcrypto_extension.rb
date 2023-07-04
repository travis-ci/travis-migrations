class CreatePgcryptoExtension < ActiveRecord::Migration[4.2]
  def up
    execute 'create extension if not exists pgcrypto'
  end

  def down
    execute 'drop extension pgcrypto'
  end
end
