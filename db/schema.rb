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

ActiveRecord::Schema[8.0].define(version: 2024_12_23_225432) do
  create_table "agencies", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_agencies_on_name", unique: true
  end

  create_table "branches", force: :cascade do |t|
    t.string "name", null: false
    t.integer "agency_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_branches_on_agency_id"
    t.index ["name", "agency_id"], name: "index_branches_on_name_and_agency_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.integer "agency_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "type"
    t.string "full_name", null: false
    t.string "telephone", null: false
    t.integer "invited_by"
    t.datetime "invited_at"
    t.boolean "confirmed", default: false
    t.integer "agency_id"
    t.integer "branch_id"
    t.integer "role"
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["telephone"], name: "index_users_on_telephone", unique: true
  end

  add_foreign_key "branches", "agencies"
  add_foreign_key "sessions", "users"
end
