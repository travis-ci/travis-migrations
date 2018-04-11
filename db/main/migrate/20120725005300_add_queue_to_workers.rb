class AddQueueToWorkers < ActiveRecord::Migration[4.2]
  def change
    add_column :workers, :queue, :string
  end
end
