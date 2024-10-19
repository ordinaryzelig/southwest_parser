class CreateFares < ActiveRecord::Migration[7.1]
  def change
    create_table :fares do |t|
      t.belongs_to :flight, null: false, foreign_key: true
      t.integer :points
      t.integer :cash
      t.boolean :available, null: false

      t.timestamps
    end
  end
end
