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

ActiveRecord::Schema[8.1].define(version: 2026_09_14_144835) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "archives", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "folder_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["folder_id"], name: "index_archives_on_folder_id"
  end

  create_table "document_versions", force: :cascade do |t|
    t.text "content_snapshot"
    t.datetime "created_at", null: false
    t.text "diff"
    t.integer "document_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["document_id"], name: "index_document_versions_on_document_id"
    t.index ["user_id"], name: "index_document_versions_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.integer "accessibility_level"
    t.datetime "created_at", null: false
    t.integer "folder_id"
    t.integer "importance_flag"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["folder_id"], name: "index_documents_on_folder_id"
  end

  create_table "folders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "status"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "archives", "folders"
  add_foreign_key "document_versions", "documents"
  add_foreign_key "document_versions", "users"
  add_foreign_key "documents", "folders"
  add_foreign_key "sessions", "users"
end
