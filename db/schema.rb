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

ActiveRecord::Schema[8.0].define(version: 2025_01_12_150436) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "branches", force: :cascade do |t|
    t.string "name", null: false
    t.string "telephone", null: false
    t.bigint "enterprise_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enterprise_id"], name: "index_branches_on_enterprise_id"
    t.index ["name", "enterprise_id"], name: "index_branches_on_name_and_enterprise_id", unique: true
    t.index ["telephone", "enterprise_id"], name: "index_branches_on_telephone_and_enterprise_id", unique: true
  end

  create_table "deliveries", force: :cascade do |t|
    t.integer "enterprise_id", null: false
    t.integer "origin_id", null: false
    t.integer "destination_id", null: false
    t.integer "sender_id", null: false
    t.integer "receiver_id", null: false
    t.integer "registered_by_id", null: false
    t.integer "checked_in_by_id"
    t.integer "checked_out_by_id"
    t.datetime "checked_in_at"
    t.datetime "checked_out_at"
    t.integer "status", default: 0
    t.string "tracking_number", null: false
    t.string "tracking_secret", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_id"], name: "index_deliveries_on_destination_id"
    t.index ["enterprise_id"], name: "index_deliveries_on_enterprise_id"
    t.index ["origin_id"], name: "index_deliveries_on_origin_id"
    t.index ["receiver_id"], name: "index_deliveries_on_receiver_id"
    t.index ["sender_id"], name: "index_deliveries_on_sender_id"
    t.index ["tracking_number", "enterprise_id"], name: "index_deliveries_on_tracking_number_and_enterprise_id"
    t.index ["tracking_secret", "enterprise_id"], name: "index_deliveries_on_tracking_secret_and_enterprise_id"
  end

  create_table "enterprises", force: :cascade do |t|
    t.string "name", null: false
    t.integer "category", default: 0
    t.jsonb "location", default: {}
    t.integer "marketer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_enterprises_on_name", unique: true
  end

  create_table "marketers", force: :cascade do |t|
    t.string "full_name"
    t.string "telephone"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "enterprises_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.integer "enterprise_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "type"
    t.string "full_name"
    t.string "telephone", null: false
    t.integer "invited_by_id"
    t.datetime "invited_at"
    t.boolean "confirmed", default: false
    t.boolean "archived", default: false
    t.integer "enterprise_id"
    t.integer "branch_id"
    t.integer "role"
    t.string "password_digest", null: false
    t.jsonb "location", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["telephone", "enterprise_id"], name: "index_users_on_telephone_and_enterprise_id", unique: true
  end

  add_foreign_key "branches", "enterprises"
  add_foreign_key "sessions", "users"
end
