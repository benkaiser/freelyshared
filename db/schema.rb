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

ActiveRecord::Schema[8.0].define(version: 2026_03_31_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "borrow_requests", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "requester_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "phone"
    t.boolean "owner_confirmed", default: false, null: false
    t.boolean "borrower_confirmed", default: false, null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "status"], name: "index_borrow_requests_on_item_id_and_status"
    t.index ["item_id"], name: "index_borrow_requests_on_item_id"
    t.index ["requester_id"], name: "index_borrow_requests_on_requester_id"
    t.index ["status"], name: "index_borrow_requests_on_status"
  end

  create_table "church_members", force: :cascade do |t|
    t.bigint "church_id"
    t.string "name", null: false
    t.string "email", default: "", null: false
    t.boolean "email_verified", default: false
    t.string "verification_token"
    t.datetime "verified_at"
    t.boolean "is_registrant", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "phone"
    t.boolean "show_email", default: false
    t.boolean "show_in_directory", default: true
    t.boolean "admin", default: false, null: false
    t.string "approval_status", default: "approved", null: false
    t.boolean "superadmin", default: false, null: false
    t.boolean "suspended", default: false, null: false
    t.datetime "suspended_at"
    t.boolean "email_notify_new_needs", default: true, null: false
    t.boolean "email_notify_new_items", default: false, null: false
    t.boolean "email_notify_new_services", default: false, null: false
    t.boolean "email_notify_church_activation", default: true, null: false
    t.index ["church_id", "approval_status"], name: "index_church_members_on_church_id_and_approval_status"
    t.index ["church_id"], name: "index_church_members_on_church_id"
    t.index ["email"], name: "index_church_members_on_email", unique: true
    t.index ["reset_password_token"], name: "index_church_members_on_reset_password_token", unique: true
    t.index ["verification_token"], name: "index_church_members_on_verification_token"
  end

  create_table "church_memberships", force: :cascade do |t|
    t.bigint "church_member_id", null: false
    t.bigint "church_id", null: false
    t.boolean "admin", default: false, null: false
    t.string "approval_status", default: "approved", null: false
    t.boolean "is_registrant", default: false, null: false
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["church_id", "approval_status"], name: "index_church_memberships_on_church_id_and_approval_status"
    t.index ["church_id"], name: "index_church_memberships_on_church_id"
    t.index ["church_member_id", "church_id"], name: "index_church_memberships_on_church_member_id_and_church_id", unique: true
    t.index ["church_member_id"], name: "index_church_memberships_on_church_member_id"
  end

  create_table "churches", force: :cascade do |t|
    t.string "name", null: false
    t.string "location_name", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.string "country_code", limit: 2
    t.string "state_code", limit: 10
    t.string "postcode", limit: 10
    t.string "status", default: "pending", null: false
    t.datetime "ready_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "require_admin_approval", default: false, null: false
    t.boolean "archived", default: false, null: false
    t.datetime "archived_at"
    t.boolean "demo", default: false, null: false
    t.datetime "last_need_email_sent_at"
    t.datetime "last_item_email_sent_at"
    t.datetime "last_service_email_sent_at"
    t.index ["latitude", "longitude"], name: "index_churches_on_latitude_and_longitude"
    t.index ["name"], name: "index_churches_on_name"
    t.index ["status"], name: "index_churches_on_status"
  end

  create_table "items", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "category", default: "Other", null: false
    t.boolean "available", default: true, null: false
    t.bigint "church_member_id", null: false
    t.bigint "church_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available"], name: "index_items_on_available"
    t.index ["category"], name: "index_items_on_category"
    t.index ["church_id", "available"], name: "index_items_on_church_id_and_available"
    t.index ["church_id"], name: "index_items_on_church_id"
    t.index ["church_member_id"], name: "index_items_on_church_member_id"
  end

  create_table "moderation_actions", force: :cascade do |t|
    t.bigint "actor_id", null: false
    t.string "action_type", null: false
    t.string "target_type", null: false
    t.bigint "target_id", null: false
    t.text "reason"
    t.bigint "church_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_moderation_actions_on_action_type"
    t.index ["actor_id"], name: "index_moderation_actions_on_actor_id"
    t.index ["church_id"], name: "index_moderation_actions_on_church_id"
    t.index ["target_type", "target_id"], name: "index_moderation_actions_on_target_type_and_target_id"
  end

  create_table "needs", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "contact_info"
    t.string "status", default: "open", null: false
    t.datetime "expires_at", null: false
    t.bigint "church_member_id", null: false
    t.bigint "church_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["church_id", "status"], name: "index_needs_on_church_id_and_status"
    t.index ["church_id"], name: "index_needs_on_church_id"
    t.index ["church_member_id"], name: "index_needs_on_church_member_id"
    t.index ["expires_at"], name: "index_needs_on_expires_at"
    t.index ["status"], name: "index_needs_on_status"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.bigint "church_member_id", null: false
    t.string "endpoint", null: false
    t.string "p256dh_key", null: false
    t.string "auth_key", null: false
    t.boolean "notify_new_needs", default: false, null: false
    t.boolean "notify_new_services", default: false, null: false
    t.boolean "notify_new_items", default: false, null: false
    t.boolean "notify_borrow_requests", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["church_member_id"], name: "index_push_subscriptions_on_church_member_id"
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
  end

  create_table "services_listings", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "contact_preference"
    t.bigint "church_member_id", null: false
    t.bigint "church_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["church_id"], name: "index_services_listings_on_church_id"
    t.index ["church_member_id"], name: "index_services_listings_on_church_member_id"
  end

  create_table "telemetry_events", force: :cascade do |t|
    t.string "event_type", null: false
    t.bigint "church_id"
    t.bigint "church_member_id"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.index ["church_id", "event_type", "created_at"], name: "idx_telemetry_church_type_time"
    t.index ["church_id"], name: "index_telemetry_events_on_church_id"
    t.index ["church_member_id"], name: "index_telemetry_events_on_church_member_id"
    t.index ["created_at"], name: "index_telemetry_events_on_created_at"
    t.index ["event_type", "created_at"], name: "index_telemetry_events_on_event_type_and_created_at"
    t.index ["event_type"], name: "index_telemetry_events_on_event_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "borrow_requests", "church_members", column: "requester_id"
  add_foreign_key "borrow_requests", "items"
  add_foreign_key "church_members", "churches"
  add_foreign_key "church_memberships", "church_members"
  add_foreign_key "church_memberships", "churches"
  add_foreign_key "items", "church_members"
  add_foreign_key "items", "churches"
  add_foreign_key "moderation_actions", "church_members", column: "actor_id"
  add_foreign_key "moderation_actions", "churches"
  add_foreign_key "needs", "church_members"
  add_foreign_key "needs", "churches"
  add_foreign_key "push_subscriptions", "church_members"
  add_foreign_key "services_listings", "church_members"
  add_foreign_key "services_listings", "churches"
  add_foreign_key "telemetry_events", "church_members"
  add_foreign_key "telemetry_events", "churches"
end
