class AddStripeInvoiceIdToInvoices < ActiveRecord::Migration
  def change
    change_table :invoices do |t|
      t.string :stripe_id
    end

    add_index :invoices, :stripe_id
  end
end
