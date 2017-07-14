class AddLastCcDigistsToInvoices < ActiveRecord::Migration
  def change
    change_table :invoices do |t|
      t.string :last_cc_digists
    end
  end
end
