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

ActiveRecord::Schema.define(version: 2021_11_21_045501) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "declines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "from_member_id"
    t.bigint "to_member_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "footprints", force: :cascade do |t|
    t.bigint "from_member_id"
    t.bigint "to_member_id"
    t.bigint "access_count"
    t.integer "is_browsed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "member_id"
    t.integer "use_type"
    t.string "filename"
    t.string "extension"
    t.integer "blur_level", default: 0
    t.integer "is_approved", default: 0
    t.integer "is_displayed", default: 0
    t.integer "is_deleted", default: 0
    t.string "token"
    t.datetime "uploaded_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "languages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "member_id"
    t.integer "language"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "from_member_id"
    t.bigint "to_member_id"
    t.integer "favorite", default: 0
    t.string "matching_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "logs", force: :cascade do |t|
    t.bigint "from_member_id"
    t.bigint "to_member_id"
    t.integer "action_id"
    t.integer "is_browsed", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["from_member_id", "to_member_id"], name: "index_logs_on_from_member_id_and_to_member_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "email", null: false
    t.string "display_name"
    t.string "family_name"
    t.string "given_name"
    t.integer "gender"
    t.integer "height"
    t.integer "weight"
    t.date "birthday"
    t.integer "salary"
    t.text "message"
    t.text "memo"
    t.string "token"
    t.string "token_for_api"
    t.string "password_digest"
    t.integer "native_language"
    t.integer "is_registered", limit: 2, default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_members_on_email", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "member_id"
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "timelines", force: :cascade do |t|
    t.bigint "from_member_id"
    t.bigint "to_member_id"
    t.integer "timeline_type"
    t.integer "message_id"
    t.integer "url_id"
    t.uuid "image_id"
    t.integer "is_browsed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["from_member_id", "to_member_id"], name: "index_timelines_on_from_member_id_and_to_member_id"
  end

  create_table "urls", force: :cascade do |t|
    t.bigint "member_id"
    t.string "url"
    t.string "title"
    t.string "thumbnail_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
