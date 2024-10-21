class AddTrialToCancellations < ActiveRecord::Migration[7.0]
  def change
    add_column :cancellations, :on_trial, :boolean, default: false
  end
end
