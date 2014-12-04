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

ActiveRecord::Schema.define(version: 20141119174300) do

  create_table "applications", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",        default: "anonymous"
    t.string   "password",        default: "password"
    t.boolean  "record_requests", default: false
  end

  add_index "applications", ["user_id"], name: "index_applications_on_user_id"

  create_table "recordings", force: true do |t|
    t.integer  "application_id"
    t.text     "request_headers"
    t.text     "request_body"
    t.string   "request_url"
    t.string   "request_method"
    t.text     "response_headers"
    t.text     "response_body"
    t.text     "response_status"
    t.integer  "request_spec_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recordings", ["application_id"], name: "index_recordings_on_application_id"
  add_index "recordings", ["request_spec_id"], name: "index_recordings_on_request_spec_id"

  create_table "request_specs", force: true do |t|
    t.integer "user_id"
    t.integer "application_id"
    t.string  "url"
    t.text    "note"
    t.integer "response_id"
    t.string  "http_method",    default: "GET"
    t.string  "url_type",       default: "url"
    t.text    "conditions",     default: "{}"
  end

  add_index "request_specs", ["application_id"], name: "index_request_specs_on_application_id"
  add_index "request_specs", ["user_id"], name: "index_request_specs_on_user_id"

  create_table "responses", force: true do |t|
    t.string   "name"
    t.text     "content"
    t.text     "json"
    t.text     "jsonp"
    t.text     "text"
    t.string   "jsonp_callback"
    t.string   "jsonp_callback_param"
    t.string   "content_type"
    t.integer  "status_code",          default: 200
    t.text     "headers",              default: "{}"
    t.boolean  "is_template"
    t.float    "delay",                default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
