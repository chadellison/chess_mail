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

ActiveRecord::Schema.define(version: 20170926040345) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "archives", force: :cascade do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pending", default: true
    t.string "challengedName"
    t.string "challengedEmail"
    t.boolean "human", default: true
    t.string "challengerColor"
    t.string "outcome"
  end

  create_table "pieces", force: :cascade do |t|
    t.string "currentPosition"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pieceType"
    t.boolean "hasMoved", default: false
    t.boolean "movedTwo", default: false
    t.integer "startIndex"
    t.integer "game_id"
  end

  create_table "training_games", force: :cascade do |t|
    t.text "moves"
    t.string "outcome"
    t.integer "move_count"
  end

  create_table "user_games", force: :cascade do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "approved", default: false
    t.string "token"
    t.string "hashed_email"
    t.string "firstName"
    t.string "lastName"
    t.index ["token"], name: "index_users_on_token"
  end

end
