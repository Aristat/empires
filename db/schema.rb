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

ActiveRecord::Schema[8.0].define(version: 2025_05_25_171700) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "build_queues", force: :cascade do |t|
    t.bigint "user_game_id", null: false
    t.integer "turn_added", default: 0, null: false
    t.integer "iron", default: 0, null: false
    t.integer "wood", default: 0, null: false
    t.integer "gold", default: 0, null: false
    t.integer "building_type", null: false
    t.integer "queue_type", null: false
    t.integer "position", null: false
    t.integer "quantity", default: 0, null: false
    t.integer "time_needed", default: 0, null: false
    t.boolean "on_hold", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_game_id", "position"], name: "index_build_queues_on_user_game_id_and_position"
    t.index ["user_game_id"], name: "index_build_queues_on_user_game_id"
  end

  create_table "buildings", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "name", null: false
    t.string "key", null: false
    t.jsonb "settings", default: {}, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "key"], name: "index_buildings_on_game_id_and_key", unique: true
    t.index ["game_id"], name: "index_buildings_on_game_id"
  end

  create_table "civilizations", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "name"
    t.string "key", null: false
    t.text "description"
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "key"], name: "index_civilizations_on_game_id_and_key", unique: true
    t.index ["game_id"], name: "index_civilizations_on_game_id"
  end

  create_table "explore_queues", force: :cascade do |t|
    t.bigint "user_game_id", null: false
    t.integer "turn", null: false
    t.integer "people", null: false
    t.integer "food", default: 0, null: false
    t.integer "m_land", default: 0, null: false
    t.integer "p_land", default: 0, null: false
    t.integer "f_land", default: 0, null: false
    t.integer "seek_land", null: false
    t.integer "horse_setting", null: false
    t.integer "horses", null: false
    t.integer "turns_used", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_game_id"], name: "index_explore_queues_on_user_game_id"
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

  create_table "soldiers", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "name", null: false
    t.string "key", null: false
    t.jsonb "settings", default: {}, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "key"], name: "index_soldiers_on_game_id_and_key", unique: true
    t.index ["game_id"], name: "index_soldiers_on_game_id"
  end

  create_table "train_queues", force: :cascade do |t|
    t.bigint "user_game_id", null: false
    t.integer "soldier_key", null: false
    t.integer "turns_remaining", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_game_id"], name: "index_train_queues_on_user_game_id"
  end

  create_table "user_games", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.bigint "civilization_id", null: false
    t.bigint "score", default: 0, null: false
    t.integer "turn", default: 0, null: false
    t.datetime "last_turn_at"
    t.integer "current_turns", default: 0, null: false
    t.integer "food_ratio", default: 0, null: false
    t.integer "tool_maker", default: 0, null: false
    t.integer "wood_cutter", default: 0, null: false
    t.integer "gold_mine", default: 0, null: false
    t.integer "hunter", default: 0, null: false
    t.integer "tower", default: 0, null: false
    t.integer "town_center", default: 0, null: false
    t.integer "market", default: 0, null: false
    t.integer "iron_mine", default: 0, null: false
    t.integer "house", default: 0, null: false
    t.integer "farm", default: 0, null: false
    t.integer "weaponsmith", default: 0, null: false
    t.integer "fort", default: 0, null: false
    t.integer "warehouse", default: 0, null: false
    t.integer "stable", default: 0, null: false
    t.integer "mage_tower", default: 0, null: false
    t.integer "winery", default: 0, null: false
    t.jsonb "buildings_statuses", default: {}, null: false
    t.integer "f_land", default: 0, null: false
    t.integer "m_land", default: 0, null: false
    t.integer "p_land", default: 0, null: false
    t.integer "wood", default: 0, null: false
    t.integer "food", default: 0, null: false
    t.integer "iron", default: 0, null: false
    t.integer "gold", default: 0, null: false
    t.integer "tools", default: 0, null: false
    t.integer "people", default: 0, null: false
    t.integer "wine", default: 0, null: false
    t.integer "horses", default: 0, null: false
    t.integer "bow_weaponsmith", default: 0, null: false
    t.integer "sword_weaponsmith", default: 0, null: false
    t.integer "mace_weaponsmith", default: 0, null: false
    t.integer "bows", default: 0, null: false
    t.integer "swords", default: 0, null: false
    t.integer "maces", default: 0, null: false
    t.integer "current_research"
    t.integer "research_points", default: 0, null: false
    t.jsonb "researches", default: {}, null: false
    t.integer "trades_this_turn", default: 0, null: false
    t.jsonb "trades", default: {}, null: false
    t.jsonb "soldiers", default: {}, null: false
    t.integer "wall", default: 0, null: false
    t.integer "wall_build_per_turn", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "last_message", default: {}, null: false
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

  add_foreign_key "build_queues", "user_games"
  add_foreign_key "buildings", "games"
  add_foreign_key "civilizations", "games"
  add_foreign_key "explore_queues", "user_games"
  add_foreign_key "soldiers", "games"
  add_foreign_key "train_queues", "user_games"
  add_foreign_key "user_games", "civilizations"
  add_foreign_key "user_games", "games"
  add_foreign_key "user_games", "users"
end
