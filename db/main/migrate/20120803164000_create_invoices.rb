class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.text :object
      t.timestamps
      t.belongs_to :subscription
    end
  end
end
