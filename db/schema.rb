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

ActiveRecord::Schema[8.0].define(version: 2025_09_01_100004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "title_ru", null: false
    t.string "title_en", null: false
    t.string "author_ru", null: false
    t.string "author_en", null: false
    t.text "description_ru", null: false
    t.text "description_en", null: false
    t.integer "year"
    t.string "image_url"
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_books_on_genre_id"
  end

  create_table "evaluations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "book_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_evaluations_on_book_id"
    t.index ["user_id", "book_id"], name: "index_evaluations_on_user_id_and_book_id", unique: true
    t.index ["user_id"], name: "index_evaluations_on_user_id"
    t.check_constraint "rating >= 1 AND rating <= 100", name: "evaluations_rating_range"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name_ru", null: false
    t.string "name_en", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_genres_on_name_en", unique: true
    t.index ["name_ru"], name: "index_genres_on_name_ru", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "books", "genres"
  add_foreign_key "evaluations", "books"
  add_foreign_key "evaluations", "users"
end
