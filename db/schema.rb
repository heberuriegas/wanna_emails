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

ActiveRecord::Schema.define(version: 20151123232254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "state"
    t.text     "report"
  end

  add_index "campaigns", ["project_id"], name: "index_campaigns_on_project_id", using: :btree
  add_index "campaigns", ["user_id"], name: "index_campaigns_on_user_id", using: :btree

  create_table "campaigns_recollections", primary_key: "[:campaign_id, :recollection_id]", force: true do |t|
    t.integer "recollection_id"
    t.integer "campaign_id"
  end

  add_index "campaigns_recollections", ["campaign_id", "recollection_id"], name: "index_campaigns_recollections", unique: true, using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", force: true do |t|
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "last_sent_at"
  end

  add_index "emails", ["address"], name: "index_emails_on_address", using: :btree

  create_table "emails_prospects", force: true do |t|
    t.integer "email_id"
    t.integer "prospect_id"
  end

  add_index "emails_prospects", ["email_id", "prospect_id"], name: "index_emails_prospects_on_email_id_and_prospect_id", unique: true, using: :btree
  add_index "emails_prospects", ["email_id"], name: "index_emails_prospects_on_email_id", using: :btree
  add_index "emails_prospects", ["prospect_id"], name: "index_emails_prospects_on_prospect_id", using: :btree

  create_table "emails_recollection_pages", primary_key: "[:email_id, :recollection_page_id]", force: true do |t|
    t.integer "email_id"
    t.integer "recollection_page_id"
  end

  add_index "emails_recollection_pages", ["email_id", "recollection_page_id"], name: "index_emails_recollection_pages_unique", unique: true, using: :btree
  add_index "emails_recollection_pages", ["email_id"], name: "index_emails_recollection_pages_on_email_id", using: :btree
  add_index "emails_recollection_pages", ["recollection_page_id"], name: "index_emails_recollection_pages_on_recollection_page_id", using: :btree

  create_table "messages", force: true do |t|
    t.string   "subject"
    t.text     "text"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["project_id"], name: "index_messages_on_project_id", using: :btree

  create_table "page_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", force: true do |t|
    t.string   "host"
    t.text     "uri"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "posted",       default: false
    t.integer  "page_type_id"
  end

  add_index "pages", ["page_type_id"], name: "index_pages_on_page_type_id", using: :btree

  create_table "pages_recollections", force: true do |t|
    t.integer "page_id"
    t.integer "recollection_id"
    t.integer "number_of_emails"
  end

  add_index "pages_recollections", ["page_id", "recollection_id"], name: "index_pages_recollections_on_page_id_and_recollection_id", unique: true, using: :btree

  create_table "phones", force: true do |t|
    t.string   "number"
    t.integer  "recollection_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "prospect_id"
  end

  add_index "phones", ["prospect_id"], name: "index_phones_on_prospect_id", using: :btree
  add_index "phones", ["recollection_page_id"], name: "index_phones_on_recollection_page_id", using: :btree

  create_table "products", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products_prospects", force: true do |t|
    t.integer "product_id"
    t.integer "prospect_id"
  end

  add_index "products_prospects", ["product_id", "prospect_id"], name: "index_products_prospects_on_product_id_and_prospect_id", unique: true, using: :btree
  add_index "products_prospects", ["product_id"], name: "index_products_prospects_on_product_id", using: :btree
  add_index "products_prospects", ["prospect_id"], name: "index_products_prospects_on_prospect_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language"
  end

  create_table "prospects", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "hours"
    t.integer  "subcategory_id"
    t.integer  "recollection_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "country",              limit: 75
    t.string   "state",                limit: 75
    t.string   "postal_code"
    t.integer  "category_id"
  end

  add_index "prospects", ["category_id"], name: "index_prospects_on_category_id", using: :btree
  add_index "prospects", ["recollection_page_id"], name: "index_prospects_on_recollection_page_id", using: :btree
  add_index "prospects", ["subcategory_id"], name: "index_prospects_on_subcategory_id", using: :btree

  create_table "recollection_pages", force: true do |t|
    t.integer  "recollection_id"
    t.integer  "page_id"
    t.integer  "emails_recollection_pages_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recollection_pages", ["page_id"], name: "index_recollection_pages_on_page_id", using: :btree
  add_index "recollection_pages", ["recollection_id"], name: "index_recollection_pages_on_recollection_id", using: :btree

  create_table "recollections", force: true do |t|
    t.string   "name"
    t.datetime "date"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "goal"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.string   "recollection"
    t.integer  "project_id"
    t.string   "search"
    t.integer  "state"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "report"
    t.string   "country_code"
    t.boolean  "search_by_city", default: false
    t.boolean  "unique_pages",   default: false
  end

  add_index "recollections", ["project_id"], name: "index_recollections_on_project_id", using: :btree
  add_index "recollections", ["user_id"], name: "index_recollections_on_user_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sender_entities", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "port"
    t.string   "domain"
    t.string   "user_name"
    t.string   "password"
    t.string   "authentication"
    t.boolean  "enable_starttls_auto"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "limit",                default: 0
    t.boolean  "full_user_name",       default: false
  end

  create_table "senders", force: true do |t|
    t.string   "name"
    t.integer  "sender_entity_id"
    t.string   "email"
    t.string   "password"
    t.string   "language"
    t.integer  "mail_sent",        default: 0
    t.boolean  "blocked",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_blocked_at"
    t.string   "phone"
  end

  add_index "senders", ["sender_entity_id"], name: "index_senders_on_sender_entity_id", using: :btree

  create_table "sent_emails", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "email_id"
    t.integer  "sender_id"
    t.integer  "message_id"
    t.date     "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sent_emails", ["campaign_id"], name: "index_sent_emails_on_campaign_id", using: :btree
  add_index "sent_emails", ["email_id"], name: "index_sent_emails_on_email_id", using: :btree
  add_index "sent_emails", ["message_id"], name: "index_sent_emails_on_message_id", using: :btree
  add_index "sent_emails", ["sender_id"], name: "index_sent_emails_on_sender_id", using: :btree
  add_index "sent_emails", ["sent_at", "email_id", "sender_id"], name: "index_sent_emails", using: :btree

  create_table "tags", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
