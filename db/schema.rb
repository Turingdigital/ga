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

ActiveRecord::Schema.define(version: 20180126081713) do

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

  create_table "checkgas", force: :cascade do |t|
    t.text     "entryUrl"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "checkgas", ["user_id"], name: "index_checkgas_on_user_id"

  create_table "demos", force: :cascade do |t|
    t.text     "ecommerce"
    t.string   "containerid"
    t.string   "gatc"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "filterforms", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "infojson"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "filterforms", ["user_id"], name: "index_filterforms_on_user_id"

  create_table "filters", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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

  create_table "ga_data", force: :cascade do |t|
    t.integer  "ga_label_id"
    t.string   "profile"
    t.text     "json"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "ga_data", ["ga_label_id"], name: "index_ga_data_on_ga_label_id"
  add_index "ga_data", ["profile"], name: "index_ga_data_on_profile"

  create_table "ga_labels", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "goals", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "goals", ["user_id"], name: "index_goals_on_user_id"

  create_table "matrixec11s", force: :cascade do |t|
    t.string   "date"
    t.string   "hour"
    t.string   "age"
    t.integer  "sessions"
    t.integer  "transactions"
    t.float    "revenue"
    t.float    "ct"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "profileid"
  end

  add_index "matrixec11s", ["profileid"], name: "index_matrixec11s_on_profileid"

  create_table "matrixec_11s", force: :cascade do |t|
    t.string   "date"
    t.string   "hour"
    t.string   "age"
    t.integer  "sessions"
    t.integer  "transactions"
    t.float    "revenue"
    t.float    "ct"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "myday_hosts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "myday_sitemaps", force: :cascade do |t|
    t.text     "url"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "host_id"
  end

  add_index "myday_sitemaps", ["end_date"], name: "index_myday_sitemaps_on_end_date"
  add_index "myday_sitemaps", ["host_id"], name: "index_myday_sitemaps_on_host_id"
  add_index "myday_sitemaps", ["start_date"], name: "index_myday_sitemaps_on_start_date"
  add_index "myday_sitemaps", ["url"], name: "index_myday_sitemaps_on_url"

  create_table "page_gas", force: :cascade do |t|
    t.text     "code"
    t.boolean  "isWorking"
    t.integer  "page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "page_gas", ["page_id"], name: "index_page_gas_on_page_id"

  create_table "page_gtms", force: :cascade do |t|
    t.text     "code"
    t.boolean  "isWorking"
    t.integer  "page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "page_gtms", ["page_id"], name: "index_page_gtms_on_page_id"

  create_table "pages", force: :cascade do |t|
    t.text     "url"
    t.integer  "checkga_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "pages", ["checkga_id"], name: "index_pages_on_checkga_id"
  add_index "pages", ["url"], name: "index_pages_on_url"

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

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
    t.integer  "twohour"
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
