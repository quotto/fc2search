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

ActiveRecord::Schema.define(version: 20160218155157) do

  create_table "movies", force: :cascade do |t|
    t.string   "movieid",      limit: 255,             null: false
    t.string   "title",        limit: 255,             null: false
    t.string   "url",          limit: 255,             null: false
    t.string   "thumbnail",    limit: 255
    t.integer  "playtime",     limit: 4,               null: false
    t.integer  "playcount",    limit: 4,   default: 0
    t.integer  "albumcount",   limit: 4,   default: 0
    t.integer  "commentcount", limit: 4,   default: 0
    t.string   "user",         limit: 255,             null: false
    t.string   "scope",        limit: 255,             null: false
    t.string   "tags",         limit: 255
    t.datetime "upload_at",                            null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "movies", ["albumcount"], name: "index_movies_on_albumcount", using: :btree
  add_index "movies", ["commentcount"], name: "index_movies_on_commentcount", using: :btree
  add_index "movies", ["movieid"], name: "index_movies_on_movieid", using: :btree
  add_index "movies", ["playcount"], name: "index_movies_on_playcount", using: :btree
  add_index "movies", ["playtime"], name: "index_movies_on_playtime", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "movieid",    limit: 255, null: false
    t.string   "tag",        limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "tags", ["movieid"], name: "index_tags_on_movieid", using: :btree

end
