class AddExpiredAtToFlightsFares < ActiveRecord::Migration[7.2]
  def change
    change_table :flights do |f|
      f.datetime :expired_at
    end
  end
end
