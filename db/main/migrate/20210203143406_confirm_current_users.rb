class ConfirmCurrentUsers < ActiveRecord::Migration[5.2]
  class User < ActiveRecord::Base
  end
  disable_ddl_transaction!

  def change
    # time_now = Time.zone.now - 21.days
    # User.all.in_batches do |users|
    #   users.update_all(confirmed_at: time_now)
    # end
  end
end
