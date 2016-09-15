class AddInvoiceIdToInvoices < ActiveRecord::Migration
  def change
    change_table :invoices do |t|
      t.string :invoice_id
    end
  end
end
