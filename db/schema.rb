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

ActiveRecord::Schema[8.0].define(version: 2025_04_19_203015) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "buildings", force: :cascade do |t|
    t.string "name", null: false
    t.string "key", null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_buildings_on_key", unique: true
  end

  create_table "civilizations", force: :cascade do |t|
    t.string "name"
    t.string "key", null: false
    t.text "description"
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_civilizations_on_key", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.integer "seconds_per_turn"
    t.integer "start_turns"
    t.integer "max_turns"
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_games", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.bigint "civilization_id", null: false
    t.integer "turn"
    t.datetime "last_turn_at"
    t.integer "current_turns"
    t.integer "food_ratio"
    t.integer "tool_maker"
    t.integer "wood_cutter"
    t.integer "gold_mine"
    t.integer "hunter"
    t.integer "tower"
    t.integer "town_center"
    t.integer "market"
    t.integer "iron_mine"
    t.integer "house"
    t.integer "farmer"
    t.integer "weaponsmith"
    t.integer "fort"
    t.integer "warehouse"
    t.integer "stable"
    t.integer "mage_tower"
    t.integer "winery"
    t.integer "hunter_status", default: 100
    t.integer "farmer_status", default: 100
    t.integer "wood_cutter_status", default: 100
    t.integer "gold_mine_status", default: 100
    t.integer "iron_mine_status", default: 100
    t.integer "tool_maker_status", default: 100
    t.integer "f_land"
    t.integer "m_land"
    t.integer "p_land"
    t.integer "swordsman"
    t.integer "archers"
    t.integer "horseman"
    t.integer "wood"
    t.integer "food"
    t.integer "iron"
    t.integer "gold"
    t.integer "tools"
    t.integer "people"
    t.integer "wine"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["civilization_id"], name: "index_user_games_on_civilization_id"
    t.index ["game_id"], name: "index_user_games_on_game_id"
    t.index ["user_id"], name: "index_user_games_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "user_games", "civilizations"
  add_foreign_key "user_games", "games"
  add_foreign_key "user_games", "users"
end
