class CreateInvoices < ActiveRecord::Migration[4.2]
  def change
    create_table :invoices do |t|
      t.text :object
      t.timestamps
      t.belongs_to :subscription
    end
  end
end
