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

ActiveRecord::Schema.define(version: 20160712101143) do

  create_table "account_summaries", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "jsonString"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "default_profile"
    t.string   "default_item"
    t.string   "default_web_property"
  end

  add_index "account_summaries", ["user_id"], name: "index_account_summaries_on_user_id"

  create_table "campaign_media", force: :cascade do |t|
    t.string   "medium"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "campaign_media", ["user_id"], name: "index_campaign_media_on_user_id"

  create_table "foos", force: :cascade do |t|
    t.string   "title"
    t.datetime "start_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ga_campaigns", force: :cascade do |t|
    t.string   "source"
    t.string   "medium"
    t.date     "date"
    t.integer  "sessions"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ga_campaigns", ["date"], name: "index_ga_campaigns_on_date"
  add_index "ga_campaigns", ["medium"], name: "index_ga_campaigns_on_medium"
  add_index "ga_campaigns", ["source"], name: "index_ga_campaigns_on_source"
  add_index "ga_campaigns", ["user_id"], name: "index_ga_campaigns_on_user_id"

  create_table "ga_credentials", force: :cascade do |t|
    t.string   "access_token"
    t.string   "refresh_token"
    t.integer  "expires_at"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "ga_credentials", ["user_id"], name: "index_ga_credentials_on_user_id"

  create_table "goals", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "goals", ["user_id"], name: "index_goals_on_user_id"

  create_table "testings", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "url_analytics", force: :cascade do |t|
    t.text     "json"
    t.integer  "url_builder_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "url_analytics", ["url_builder_id"], name: "index_url_analytics_on_url_builder_id"

  create_table "url_builder_campaign_mediumships", force: :cascade do |t|
    t.integer  "url_builder_id"
    t.integer  "campaign_medium_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "url_builder_campaign_mediumships", ["campaign_medium_id"], name: "index_url_builder_campaign_mediumships_on_campaign_medium_id"
  add_index "url_builder_campaign_mediumships", ["url_builder_id"], name: "index_url_builder_campaign_mediumships_on_url_builder_id"

  create_table "url_builders", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "url"
    t.string   "source"
    t.string   "term"
    t.string   "content"
    t.string   "name"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "campaign_medium_id"
    t.string   "short_url"
    t.string   "profile"
  end

  add_index "url_builders", ["campaign_medium_id"], name: "index_url_builders_on_campaign_medium_id"
  add_index "url_builders", ["end_date"], name: "index_url_builders_on_end_date"
  add_index "url_builders", ["profile"], name: "index_url_builders_on_profile"
  add_index "url_builders", ["start_date"], name: "index_url_builders_on_start_date"
  add_index "url_builders", ["user_id"], name: "index_url_builders_on_user_id"

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
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
