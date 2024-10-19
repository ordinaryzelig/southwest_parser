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

ActiveRecord::Schema[7.1].define(version: 2024_10_19_034253) do
  create_table "fares", force: :cascade do |t|
    t.integer "flight_id", null: false
    t.integer "points"
    t.integer "cash"
    t.boolean "available", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id"], name: "index_fares_on_flight_id"
  end

  create_table "flights", force: :cascade do |t|
    t.datetime "dep_at", null: false
    t.datetime "arr_at", null: false
    t.integer "duration", null: false
    t.integer "stops", null: false
    t.string "layover_airports", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "fares", "flights"
end
