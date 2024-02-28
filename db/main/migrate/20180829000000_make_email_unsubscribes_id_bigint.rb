# frozen_string_literal: true

class MakeEmailUnsubscribesIdBigint < ActiveRecord::Migration[4.2]
  def up
    change_column :email_unsubscribes, :id, :bigint
  end

  def down
    change_column :email_unsubscribes, :id, :integer
  end
end
