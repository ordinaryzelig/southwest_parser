class CreateFares < ActiveRecord::Migration[7.1]
  def change
    create_table :fares do |t|
      t.belongs_to :flight, null: false, foreign_key: true, :index => false
      t.integer :points
      t.integer :cash
      t.boolean :available, null: false

      t.timestamps
    end
    add_index :fares, :flight_id, :unique => true
  end
end
