class AddLastCcDigestToInvoices < ActiveRecord::Migration
  def change
    change_table :invoices do |t|
      t.string :last_cc_digest
    end
  end
end
