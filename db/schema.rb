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

ActiveRecord::Schema[8.0].define(version: 2025_09_28_123502) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "geographic_signups", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "suburb_name", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.string "country_code", limit: 2
    t.string "state_code", limit: 10
    t.string "postcode", limit: 10
    t.boolean "email_verified", default: false
    t.string "verification_token"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_geographic_signups_on_email", unique: true
    t.index ["latitude", "longitude"], name: "index_geographic_signups_on_latitude_and_longitude"
    t.index ["suburb_name", "country_code"], name: "index_geographic_signups_on_suburb_name_and_country_code"
    t.index ["verification_token"], name: "index_geographic_signups_on_verification_token"
  end
end
