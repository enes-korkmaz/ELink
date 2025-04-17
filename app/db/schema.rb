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

ActiveRecord::Schema[7.2].define(version: 2025_01_16_215117) do
  create_table "accommodations", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name"
    t.string "status"
    t.datetime "booking_deadline"
    t.json "address"
    t.json "contact"
    t.text "notes"
    t.datetime "gendate"
    t.datetime "moddate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_accommodations_on_project_id"
  end

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

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_experts", id: false, force: :cascade do |t|
    t.integer "expert_id", null: false
    t.integer "category_id", null: false
  end

  create_table "categories_projects", id: false, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "category_id", null: false
  end

  create_table "caterings", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "location_name"
    t.string "status"
    t.datetime "booking_deadline"
    t.json "address"
    t.json "contact"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_caterings_on_project_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "name"
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents_projects", id: false, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "document_id", null: false
  end

  create_table "experts", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "email", null: false
    t.string "phone_number", null: false
    t.string "nationality", null: false
    t.string "travel_willingness_text"
    t.string "institution_name", null: false
    t.string "free_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "last_name", null: false
    t.integer "hourly_rate", default: 0, null: false
    t.integer "daily_rate", default: 0, null: false
    t.integer "salutation", default: 0, null: false
    t.string "current_location", null: false
    t.integer "language_id", null: false
    t.boolean "has_institution", default: false, null: false
    t.text "cooperation_options"
    t.boolean "travel_willingness_online", default: false, null: false
    t.boolean "travel_willingness_germany", default: false, null: false
    t.boolean "travel_willingness_china", default: false, null: false
    t.string "china_reference", null: false
    t.string "spontaneous", null: false
    t.boolean "has_china_reference", default: false, null: false
    t.json "extra_skills"
    t.integer "user_id", null: false
    t.index ["language_id"], name: "index_experts_on_language_id"
    t.index ["user_id"], name: "index_experts_on_user_id"
    t.check_constraint "(has_china_reference = false OR china_reference IS NOT NULL)", name: "china_reference_null_constraint"
    t.check_constraint "(has_institution = false OR (has_institution = true AND institution_name IS NOT NULL))", name: "institution_name_presence"
    t.check_constraint "(travel_willingness_online = true OR travel_willingness_germany = true OR travel_willingness_china = true)"
  end

  create_table "experts_languages", id: false, force: :cascade do |t|
    t.integer "expert_id", null: false
    t.integer "language_id", null: false
  end

  create_table "experts_projects", id: false, force: :cascade do |t|
    t.integer "expert_id", null: false
    t.integer "project_id", null: false
    t.index ["expert_id", "project_id"], name: "index_experts_projects_on_expert_id_and_project_id", unique: true
    t.index ["expert_id"], name: "index_experts_projects_on_expert_id"
    t.index ["project_id"], name: "index_experts_projects_on_project_id"
  end

  create_table "key_topics", force: :cascade do |t|
    t.string "topic_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "languages", force: :cascade do |t|
    t.string "language"
    t.string "language_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "partners", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "location_name"
    t.json "address"
    t.json "contact"
    t.datetime "deadline"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_partners_on_project_id"
  end

  create_table "project_types", force: :cascade do |t|
    t.string "type_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string "project_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "key_topic"
    t.date "project_date_from"
    t.date "project_date_to"
    t.json "project_type"
    t.string "project_client"
    t.json "execution_locations"
    t.string "target_audience"
    t.string "flight_data"
    t.integer "invitation_status", default: 0, null: false
    t.integer "certificate_status", default: 0, null: false
    t.integer "project_status", default: 0, null: false
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "flight_details"
    t.json "accompanying_person"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_schedules_on_project_id"
  end

  create_table "transports", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "transport_type"
    t.string "company_name"
    t.string "status"
    t.datetime "booking_deadline"
    t.json "contact"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_transports_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "registration_token"
    t.integer "expert_id"
    t.index ["expert_id"], name: "index_users_on_expert_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "accommodations", "projects"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "caterings", "projects"
  add_foreign_key "experts", "languages"
  add_foreign_key "experts", "users"
  add_foreign_key "partners", "projects"
  add_foreign_key "schedules", "projects"
  add_foreign_key "transports", "projects"
  add_foreign_key "users", "experts"
end
