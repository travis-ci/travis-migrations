# frozen_string_literal: true

class AddBillingEmailCreditCardDataToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    change_table :subscriptions do |t|
      t.string :cc_owner
      t.string :cc_last_digits
      t.string :cc_expiration_date
      t.string :billing_email
    end
  end
end
