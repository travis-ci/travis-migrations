# frozen_string_literal: true

class AddStripeInvoiceIdToInvoices < ActiveRecord::Migration[4.2]
  def change
    change_table :invoices do |t|
      t.string :stripe_id
    end

    add_index :invoices, :stripe_id
  end
end
