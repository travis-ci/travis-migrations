class AddCcLastDigitsToInvoices < ActiveRecord::Migration
  def change
    change_table :invoices do |t|
      t.string :cc_last_digits
    end
  end
end
