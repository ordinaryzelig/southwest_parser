class AiirportLayoversNull < ActiveRecord::Migration[7.2]
  def change
    change_column_null :flights, :layover_airports, true
  end
end
