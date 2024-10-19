class CreateFlights < ActiveRecord::Migration[7.1]
  def change
    create_table :flights do |t|
      t.datetime :dep_at, :null => false
      t.datetime :arr_at, :null => false
      t.integer :duration, :null => false
      t.integer :stops, :null => false
      t.string :layover_airports, :null => false

      t.timestamps
    end
  end
end
