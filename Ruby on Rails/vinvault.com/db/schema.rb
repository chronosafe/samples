# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20131112212224) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_logs", force: true do |t|
    t.integer  "user_id"
    t.integer  "decode_id"
    t.text     "message"
    t.datetime "created_at"
  end

  create_table "batches", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "size"
    t.boolean  "completed"
    t.string   "batch_file_file_name"
    t.string   "batch_file_content_type"
    t.integer  "batch_file_file_size"
    t.datetime "batch_file_updated_at"
    t.integer  "total"
    t.integer  "successful"
    t.string   "outfile"
  end

  create_table "categories", force: true do |t|
    t.string  "name"
    t.string  "unit"
    t.string  "label"
    t.string  "tag"
    t.integer "group_id"
    t.boolean "enabled",   default: true
    t.string  "data_type", default: "Modern"
  end

  add_index "categories", ["name"], name: "index_categories_on_name", using: :btree

  create_table "classic_categories", force: true do |t|
    t.string  "name"
    t.integer "classic_group_id"
    t.string  "unit"
    t.string  "label"
    t.boolean "enabled",          default: true
    t.string  "code"
  end

  add_index "classic_categories", ["code"], name: "index_classic_categories_on_code", unique: true, using: :btree

  create_table "classic_groups", force: true do |t|
    t.string  "name"
    t.string  "label"
    t.boolean "enabled"
  end

  create_table "classic_item_options", force: true do |t|
    t.integer "classic_item_id"
    t.string  "value"
    t.string  "code"
  end

  add_index "classic_item_options", ["classic_item_id", "value"], name: "index_classic_item_options_on_classic_item_id_and_value", using: :btree

  create_table "classic_items", force: true do |t|
    t.integer "classic_category_id"
    t.integer "classic_vehicle_id"
    t.string  "value"
    t.string  "unit"
    t.string  "conditional"
    t.string  "condition_value"
  end

  add_index "classic_items", ["classic_vehicle_id", "value"], name: "index_classic_items_on_classic_vehicle_id_and_value", using: :btree

  create_table "classic_pattern_associations", force: true do |t|
    t.integer "classic_pattern_id"
    t.integer "classic_pattern_group_id"
  end

  create_table "classic_pattern_groups", force: true do |t|
  end

  create_table "classic_patterns", force: true do |t|
    t.string "value"
  end

  add_index "classic_patterns", ["value"], name: "index_classic_patterns_on_value", using: :btree

  create_table "classic_serials", force: true do |t|
    t.integer "digits"
    t.integer "start_value"
    t.integer "end_value"
    t.integer "classic_pattern_id"
    t.string  "prefix"
  end

  create_table "classic_vehicles", force: true do |t|
    t.integer "classic_pattern_id"
    t.string  "year"
    t.string  "make"
    t.string  "series"
    t.string  "name"
    t.string  "image"
  end

  create_table "decode_statuses", force: true do |t|
    t.integer "decode_id"
    t.integer "status_id"
  end

  create_table "decoder_logs", force: true do |t|
    t.integer  "decode_id"
    t.string   "ip_address"
    t.datetime "created_at"
    t.integer  "user_id"
    t.integer  "decode_type"
  end

  add_index "decoder_logs", ["decode_id"], name: "index_decoder_logs_on_decode_id", using: :btree
  add_index "decoder_logs", ["user_id"], name: "index_decoder_logs_on_user_id", using: :btree

  create_table "decodes", force: true do |t|
    t.string   "vin"
    t.integer  "user_id"
    t.integer  "pattern_id"
    t.boolean  "success"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "status"
    t.integer  "status_id"
    t.integer  "version"
    t.integer  "selected_id"
    t.string   "pattern_type", default: "Pattern"
  end

  add_index "decodes", ["created_at"], name: "index_decodes_on_created_at", using: :btree
  add_index "decodes", ["user_id", "vin"], name: "index_decodes_on_user_id_and_vin", using: :btree
  add_index "decodes", ["user_id"], name: "index_decodes_on_user_id", using: :btree
  add_index "decodes", ["vin"], name: "index_decodes_on_vin", using: :btree

  create_table "free_subscriptions", force: true do |t|
    t.datetime "expires_on"
    t.boolean  "active"
    t.string   "note"
  end

  create_table "fuel_econs", force: true do |t|
    t.string  "barrels08"
    t.string  "barrelsA08"
    t.string  "charge120"
    t.string  "charge240"
    t.string  "city08"
    t.string  "city08U"
    t.string  "cityA08"
    t.string  "cityA08U"
    t.string  "cityCD"
    t.string  "cityE"
    t.string  "cityUF"
    t.string  "co2"
    t.string  "co2A"
    t.string  "co2TailpipeAGpm"
    t.string  "co2TailpipeGpm"
    t.string  "comb08"
    t.string  "comb08U"
    t.string  "combA08"
    t.string  "combA08U"
    t.string  "combE"
    t.string  "combinedCD"
    t.string  "combinedUF"
    t.string  "cylinders"
    t.string  "displ"
    t.string  "drive"
    t.string  "engId"
    t.string  "eng_dscr"
    t.string  "feScore"
    t.string  "fuelCost08"
    t.string  "fuelCostA08"
    t.string  "fuelType"
    t.string  "fuelType1"
    t.string  "ghgScore"
    t.string  "ghgScoreA"
    t.string  "highway08"
    t.string  "highway08U"
    t.string  "highwayA08"
    t.string  "highwayA08U"
    t.string  "highwayCD"
    t.string  "highwayE"
    t.string  "highwayUF"
    t.string  "hlv"
    t.string  "hpv"
    t.string  "lv2"
    t.string  "lv4"
    t.string  "make"
    t.string  "model"
    t.string  "mpgData"
    t.string  "phevBlended"
    t.string  "pv2"
    t.string  "pv4"
    t.string  "range"
    t.string  "rangeCity"
    t.string  "rangeCityA"
    t.string  "rangeHwy"
    t.string  "rangeHwyA"
    t.string  "trany"
    t.string  "UCity"
    t.string  "UCityA"
    t.string  "UHighway"
    t.string  "UHighwayA"
    t.string  "VClass"
    t.string  "year"
    t.string  "youSaveSpend"
    t.string  "guzzler"
    t.string  "trans_dscr"
    t.string  "tCharger"
    t.string  "sCharger"
    t.string  "atvType"
    t.string  "fuelType2"
    t.string  "rangeA"
    t.string  "evMotor"
    t.string  "mfrCode"
    t.integer "vehicle_id"
  end

  create_table "groups", force: true do |t|
    t.string "name"
    t.string "code"
    t.string "data_type", default: "Modern"
  end

  create_table "invoice_subscriptions", force: true do |t|
    t.string  "address_1"
    t.string  "address_2"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
    t.boolean "active"
  end

  create_table "item_options", force: true do |t|
    t.integer "item_id"
    t.string  "value"
  end

  add_index "item_options", ["item_id"], name: "index_item_options_on_item_id", using: :btree

  create_table "items", force: true do |t|
    t.string  "value"
    t.integer "vehicle_id"
    t.integer "category_id"
  end

  add_index "items", ["category_id", "vehicle_id"], name: "index_items_on_category_id_and_vehicle_id", using: :btree
  add_index "items", ["category_id"], name: "index_items_on_category_id", using: :btree
  add_index "items", ["vehicle_id"], name: "index_items_on_vehicle_id", using: :btree

  create_table "patterns", force: true do |t|
    t.string   "value"
    t.string   "year"
    t.string   "make"
    t.string   "series"
    t.datetime "refreshed_at"
    t.boolean  "update_needed", default: false
    t.boolean  "concrete",      default: false
    t.string   "vin"
    t.integer  "source",        default: 0
    t.text     "cache"
  end

  add_index "patterns", ["make"], name: "index_patterns_on_make", using: :btree
  add_index "patterns", ["series"], name: "index_patterns_on_series", using: :btree
  add_index "patterns", ["value"], name: "index_patterns_on_value", using: :btree
  add_index "patterns", ["year"], name: "index_patterns_on_year", using: :btree

  create_table "plans", force: true do |t|
    t.integer "role_id"
    t.string  "name"
    t.integer "ip"
    t.integer "per_day"
    t.integer "per_month"
    t.integer "bulk_decodes"
    t.string  "decode_type"
    t.string  "description"
    t.string  "color"
    t.boolean "public"
    t.integer "price"
    t.integer "order"
  end

  create_table "posts", force: true do |t|
    t.string "title"
    t.text   "body"
  end

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "statuses", force: true do |t|
    t.string  "name"
    t.string  "code"
    t.string  "message"
    t.boolean "success"
  end

  create_table "stripe_subscriptions", force: true do |t|
    t.string  "last_4_digits"
    t.string  "customer_id"
    t.boolean "trial"
    t.boolean "active"
    t.integer "user_id"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "authentication_token"
    t.boolean  "admin"
    t.string   "name"
    t.boolean  "verbose",                default: false
    t.boolean  "trial",                  default: false
    t.string   "subscription_type"
    t.integer  "subscription_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "vehicle_caches", force: true do |t|
    t.integer "version"
    t.text    "value"
    t.integer "pattern_id"
  end

  add_index "vehicle_caches", ["pattern_id", "version"], name: "index_vehicle_caches_on_pattern_id_and_version", unique: true, using: :btree

  create_table "vehicles", force: true do |t|
    t.integer "pattern_id"
    t.string  "trim"
  end

  add_index "vehicles", ["pattern_id"], name: "index_vehicles_on_pattern_id", using: :btree

end
