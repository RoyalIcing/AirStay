# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161123032354) do

  create_table "listing_provisions", force: :cascade do |t|
    t.integer  "listing_id",                     null: false
    t.date     "start_date",                     null: false
    t.integer  "guests_max",         default: 1, null: false
    t.integer  "bedroom_count",      default: 1, null: false
    t.integer  "bed_count",          default: 1, null: false
    t.integer  "nights_min",         default: 1, null: false
    t.integer  "nightly_fee_cents",              null: false
    t.integer  "cleaning_fee_cents",             null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["listing_id", "start_date"], name: "index_listing_provisions_on_listing_id_and_start_date", unique: true
    t.index ["listing_id"], name: "index_listing_provisions_on_listing_id"
  end

  create_table "listings", force: :cascade do |t|
    t.integer  "host_id"
    t.integer  "region_id"
    t.string   "address"
    t.decimal  "lat",        precision: 9, scale: 6
    t.decimal  "lng",        precision: 9, scale: 6
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["address"], name: "index_listings_on_address", unique: true
    t.index ["host_id"], name: "index_listings_on_host_id"
    t.index ["region_id"], name: "index_listings_on_region_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "guest_id"
    t.integer  "listing_id"
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guest_id"], name: "index_messages_on_guest_id"
    t.index ["listing_id"], name: "index_messages_on_listing_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "regions", force: :cascade do |t|
    t.string   "name"
    t.string   "country_code"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["country_code"], name: "index_regions_on_country_code"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "trip_id",                            null: false
    t.text     "content",                            null: false
    t.decimal  "rating",     precision: 2, scale: 1, null: false
    t.boolean  "from_guest",                         null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["trip_id"], name: "index_reviews_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.integer  "guest_id"
    t.integer  "listing_id"
    t.date     "check_in_date",                null: false
    t.date     "check_out_date",               null: false
    t.string   "stripe_charge_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "guest_count",      default: 1, null: false
    t.index ["guest_id", "listing_id", "check_in_date"], name: "index_trips_on_guest_id_and_listing_id_and_check_in_date"
    t.index ["guest_id"], name: "index_trips_on_guest_id"
    t.index ["listing_id"], name: "index_trips_on_listing_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
