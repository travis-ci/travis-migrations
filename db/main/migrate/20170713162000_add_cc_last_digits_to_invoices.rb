# frozen_string_literal: true

class AddCcLastDigitsToInvoices < ActiveRecord::Migration[4.2]
  def change
    change_table :invoices do |t|
      t.string :cc_last_digits
    end
  end
end
