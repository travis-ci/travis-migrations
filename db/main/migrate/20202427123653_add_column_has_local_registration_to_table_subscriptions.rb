# frozen_string_literal: true

class AddColumnHasLocalRegistrationToTableSubscriptions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :subscriptions, :has_local_registration, :boolean, default: nil
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :subscriptions, :has_local_registration
    end
  end
end
