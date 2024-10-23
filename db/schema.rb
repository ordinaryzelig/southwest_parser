# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_10_23_204300) do
  create_table "fares", force: :cascade do |t|
    t.integer "flight_id", null: false
    t.integer "points"
    t.integer "cash"
    t.boolean "available", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id"], name: "index_fares_on_flight_id", unique: true
  end

  create_table "flights", force: :cascade do |t|
    t.string "dep", null: false
    t.string "arr", null: false
    t.datetime "dep_at", null: false
    t.datetime "arr_at", null: false
    t.integer "duration", null: false
    t.integer "stops", null: false
    t.string "layover_airports"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dep", "arr", "dep_at", "arr_at"], name: "index_flights_on_dep_and_arr_and_dep_at_and_arr_at", unique: true
  end

  add_foreign_key "fares", "flights"
end
