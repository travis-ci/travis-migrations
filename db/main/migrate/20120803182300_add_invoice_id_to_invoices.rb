class AddInvoiceIdToInvoices < ActiveRecord::Migration[4.2]
  def change
    change_table :invoices do |t|
      t.string :invoice_id
    end
  end
end
