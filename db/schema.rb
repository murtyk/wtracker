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

ActiveRecord::Schema.define(version: 2023_04_12_192320) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "account_states", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_states_on_account_id"
    t.index ["state_id"], name: "index_account_states_on_state_id"
  end

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "description", limit: 255, null: false
    t.integer "client_type", null: false
    t.integer "status", null: false
    t.string "subdomain", limit: 255, null: false
    t.string "logo_file", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "options"
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "line1", limit: 255
    t.string "line2", limit: 255
    t.string "city", limit: 30, null: false
    t.string "county", limit: 255
    t.string "state", limit: 2, null: false
    t.string "zip", limit: 10, null: false
    t.string "country", limit: 255
    t.integer "account_id", null: false
    t.integer "addressable_id"
    t.string "addressable_type", limit: 255
    t.string "type", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.boolean "gmaps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "county_id"
    t.index ["account_id", "addressable_id", "addressable_type"], name: "addresses_index"
    t.index ["account_id"], name: "index_addresses_on_account_id"
  end

  create_table "admins", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_token", default: ""
    t.index ["auth_token"], name: "index_admins_on_auth_token", unique: true
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "agents", id: :serial, force: :cascade do |t|
    t.hstore "info"
    t.integer "identifiable_id"
    t.string "identifiable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["identifiable_id", "identifiable_type"], name: "index_agents_on_identifiable_id_and_identifiable_type"
  end

  create_table "applicant_reapplies", id: :serial, force: :cascade do |t|
    t.integer "applicant_id"
    t.integer "account_id"
    t.integer "grant_id"
    t.string "key", limit: 255
    t.boolean "used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_applicant_reapplies_on_account_id"
    t.index ["applicant_id"], name: "index_applicant_reapplies_on_applicant_id"
    t.index ["grant_id"], name: "index_applicant_reapplies_on_grant_id"
  end

  create_table "applicant_references", id: :serial, force: :cascade do |t|
    t.string "reference", limit: 255
    t.integer "account_id"
    t.integer "grant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_applicant_references_on_account_id"
    t.index ["grant_id"], name: "index_applicant_references_on_grant_id"
  end

  create_table "applicant_sources", id: :serial, force: :cascade do |t|
    t.string "source", limit: 255
    t.integer "account_id"
    t.integer "grant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_applicant_sources_on_account_id"
    t.index ["grant_id"], name: "index_applicant_sources_on_grant_id"
  end

  create_table "applicant_special_services", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "grant_id"
    t.integer "special_service_id"
    t.integer "applicant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_applicant_special_services_on_account_id"
    t.index ["applicant_id"], name: "index_applicant_special_services_on_applicant_id"
    t.index ["grant_id"], name: "index_applicant_special_services_on_grant_id"
    t.index ["special_service_id"], name: "index_applicant_special_services_on_special_service_id"
  end

  create_table "applicant_unemployment_proofs", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "grant_id"
    t.integer "unemployment_proof_id"
    t.integer "applicant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_applicant_unemployment_proofs_on_account_id"
    t.index ["applicant_id"], name: "index_applicant_unemployment_proofs_on_applicant_id"
    t.index ["grant_id"], name: "index_applicant_unemployment_proofs_on_grant_id"
    t.index ["unemployment_proof_id"], name: "index_applicant_unemployment_proofs_on_unemployment_proof_id"
  end

  create_table "applicants", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "grant_id", null: false
    t.integer "trainee_id"
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "address_line1", limit: 255
    t.string "address_line2", limit: 255
    t.string "address_city", limit: 255
    t.string "address_state", limit: 255
    t.string "address_zip", limit: 255
    t.string "email", limit: 255
    t.string "mobile_phone_no", limit: 255
    t.date "last_employed_on"
    t.string "current_employment_status", limit: 255
    t.string "last_job_title", limit: 255
    t.string "salary_expected", limit: 255
    t.string "education_level", limit: 255
    t.boolean "transportation"
    t.boolean "computer_access"
    t.text "resume"
    t.boolean "signature"
    t.text "comments"
    t.string "status", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "county_id"
    t.integer "legal_status"
    t.boolean "veteran"
    t.string "last_employer_name", limit: 255
    t.string "last_employer_city", limit: 255
    t.string "last_employer_state", limit: 255
    t.integer "navigator_id"
    t.integer "sector_id"
    t.string "gender", limit: 255
    t.string "last_employer_manager_name", limit: 255
    t.string "last_employer_manager_phone_no", limit: 255
    t.string "last_employer_manager_email", limit: 255
    t.string "last_employer_line1", limit: 255
    t.string "last_employer_line2", limit: 255
    t.string "last_employer_zip", limit: 255
    t.string "last_wages", limit: 255
    t.integer "race_id"
    t.string "source", limit: 255
    t.string "unemployment_proof", limit: 255
    t.date "applied_on"
    t.hstore "data"
    t.date "dob"
    t.index ["account_id"], name: "index_applicants_on_account_id"
    t.index ["email"], name: "index_applicants_on_email", unique: true
    t.index ["grant_id"], name: "index_applicants_on_grant_id"
    t.index ["race_id"], name: "index_applicants_on_race_id"
    t.index ["trainee_id"], name: "index_applicants_on_trainee_id"
  end

  create_table "assessments", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "name", limit: 255
    t.integer "administered_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "grant_id"
    t.index ["account_id"], name: "index_assessments_on_account_id"
    t.index ["grant_id"], name: "index_assessments_on_grant_id"
  end

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "email_id"
    t.string "name", limit: 255
    t.string "file", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_attachments_on_account_id"
    t.index ["email_id"], name: "index_attachments_on_email_id"
  end

  create_table "auto_lead_email_texts", id: :serial, force: :cascade do |t|
    t.string "type", limit: 255
    t.text "content"
    t.integer "account_id"
    t.integer "grant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_auto_lead_email_texts_on_account_id"
    t.index ["grant_id"], name: "index_auto_lead_email_texts_on_grant_id"
  end

  create_table "auto_shared_jobs", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "trainee_id"
    t.string "title", limit: 255
    t.string "company", limit: 255
    t.datetime "date_posted"
    t.string "location", limit: 255
    t.text "excerpt"
    t.text "url"
    t.integer "status"
    t.text "feedback"
    t.string "key", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "notes"
    t.date "notes_updated_at"
    t.date "status_updated_at"
    t.index ["trainee_id"], name: "index_auto_shared_jobs_on_trainee_id"
  end

  create_table "certificate_categories", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.integer "account_id"
    t.integer "grant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_certificate_categories_on_account_id"
    t.index ["grant_id"], name: "index_certificate_categories_on_grant_id"
  end

  create_table "cities", id: :serial, force: :cascade do |t|
    t.integer "state_id", null: false
    t.string "state_code", limit: 255, null: false
    t.string "zip", limit: 255
    t.string "city_state", limit: 255, null: false
    t.integer "county_id", null: false
    t.string "name", limit: 255, null: false
    t.float "longitude", null: false
    t.float "latitude", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_state"], name: "index_cities_on_city_state"
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "colleges", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_colleges_on_account_id"
  end

  create_table "contact_emails", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "email_id"
    t.integer "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_contact_emails_on_account_id"
    t.index ["contact_id"], name: "index_contact_emails_on_contact_id"
    t.index ["email_id"], name: "index_contact_emails_on_email_id"
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.integer "contactable_id"
    t.string "contactable_type", limit: 255
    t.string "first", limit: 255
    t.string "last", limit: 255
    t.string "title", limit: 255
    t.string "land_no", limit: 255
    t.string "ext", limit: 255
    t.string "mobile_no", limit: 255
    t.string "email", limit: 255
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "contactable_type", "contactable_id"], name: "contacts_index"
  end

  create_table "counties", id: :serial, force: :cascade do |t|
    t.integer "state_id", null: false
    t.string "name", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_counties_on_state_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.string "queue", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "educations", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
  end

  create_table "emails", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.string "subject", limit: 255
    t.text "content"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "trainee_file_ids"
    t.index ["account_id"], name: "index_emails_on_account_id"
    t.index ["user_id"], name: "index_emails_on_user_id"
  end

  create_table "employer_files", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "employer_id"
    t.string "file"
    t.integer "user_id"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_employer_files_on_account_id"
    t.index ["employer_id"], name: "index_employer_files_on_employer_id"
    t.index ["user_id"], name: "index_employer_files_on_user_id"
  end

  create_table "employer_notes", id: :serial, force: :cascade do |t|
    t.integer "employer_id", null: false
    t.integer "account_id", null: false
    t.text "note", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "employer_id"], name: "index_employer_notes_on_account_id_and_employer_id"
  end

  create_table "employer_sectors", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "employer_id", null: false
    t.integer "sector_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "employer_id"], name: "index_employer_sectors_on_account_id_and_employer_id"
    t.index ["account_id", "sector_id"], name: "index_employer_sectors_on_account_id_and_sector_id"
  end

  create_table "employer_sources", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "grant_id"
    t.index ["account_id"], name: "index_employer_sources_on_account_id"
  end

  create_table "employers", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_no", limit: 255
    t.string "website", limit: 255
    t.integer "employer_source_id"
    t.index ["account_id"], name: "index_employers_on_account_id"
    t.index ["employer_source_id"], name: "index_employers_on_employer_source_id"
  end

  create_table "employment_statuses", id: :serial, force: :cascade do |t|
    t.string "status", limit: 255
    t.integer "grant_id"
    t.integer "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "action", limit: 255
    t.string "email_subject", limit: 255
    t.text "email_body"
    t.boolean "pre_selected"
    t.index ["account_id"], name: "index_employment_statuses_on_account_id"
    t.index ["grant_id"], name: "index_employment_statuses_on_grant_id"
  end

  create_table "funding_sources", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "grant_id"
    t.boolean "skip_auto_leads"
    t.index ["account_id"], name: "index_funding_sources_on_account_id"
  end

  create_table "google_places_searches", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "city_id"
    t.float "score"
    t.integer "opero_company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "city_id"], name: "index_google_places_searches_on_name_and_city_id"
    t.index ["opero_company_id"], name: "index_google_places_searches_on_opero_company_id"
  end

  create_table "grant_admins", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "grant_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_grant_admins_on_account_id"
    t.index ["grant_id"], name: "index_grant_admins_on_grant_id"
    t.index ["user_id"], name: "index_grant_admins_on_user_id"
  end

  create_table "grant_job_lead_counts", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "grant_id"
    t.date "sent_on"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_grant_job_lead_counts_on_account_id"
    t.index ["grant_id"], name: "index_grant_job_lead_counts_on_grant_id"
  end

  create_table "grants", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "status", null: false
    t.integer "spots"
    t.integer "amount"
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "options"
    t.hstore "specific_data"
    t.index ["account_id"], name: "index_grants_on_account_id"
  end

  create_table "hot_jobs", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "user_id"
    t.integer "employer_id"
    t.date "date_posted"
    t.date "closing_date"
    t.string "title"
    t.string "description"
    t.string "salary"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_hot_jobs_on_account_id"
    t.index ["employer_id"], name: "index_hot_jobs_on_employer_id"
    t.index ["user_id"], name: "index_hot_jobs_on_user_id"
  end

  create_table "import_fails", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "import_status_id"
    t.text "row_data"
    t.string "error_message", limit: 255
    t.boolean "can_retry"
    t.boolean "geocoder_fail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "row_no"
    t.index ["account_id"], name: "index_import_fails_on_account_id"
    t.index ["import_status_id"], name: "index_import_fails_on_import_status_id"
  end

  create_table "import_statuses", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "user_id"
    t.string "file_name", limit: 255
    t.string "type", limit: 255
    t.integer "rows_successful"
    t.integer "rows_failed"
    t.string "sector_ids", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "klass_id"
    t.text "params"
    t.string "status", limit: 255
    t.text "data"
    t.text "aws_file_name"
    t.index ["account_id"], name: "index_import_statuses_on_account_id"
  end

  create_table "job_openings", id: :serial, force: :cascade do |t|
    t.integer "jobs_no"
    t.string "skills", limit: 255
    t.integer "employer_id", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "employer_id"], name: "index_job_openings_on_account_id_and_employer_id"
  end

  create_table "job_search_profiles", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "trainee_id"
    t.text "skills"
    t.string "location", limit: 255
    t.integer "distance"
    t.string "key", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "opted_out"
    t.string "opt_out_reason", limit: 255
    t.string "company_name", limit: 255
    t.string "title", limit: 255
    t.string "salary", limit: 255
    t.string "zip", limit: 255
    t.date "start_date"
    t.integer "opt_out_reason_code"
    t.index ["account_id"], name: "index_job_search_profiles_on_account_id"
    t.index ["trainee_id"], name: "index_job_search_profiles_on_trainee_id"
  end

  create_table "job_searches", id: :serial, force: :cascade do |t|
    t.string "keywords", limit: 255
    t.string "location", limit: 255
    t.integer "user_id"
    t.integer "account_id", null: false
    t.integer "distance"
    t.integer "recruiters"
    t.integer "days"
    t.integer "klass_title_id"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "in_state"
    t.index ["account_id", "user_id"], name: "index_job_searches_on_account_id_and_user_id"
    t.index ["account_id"], name: "index_job_searches_on_account_id"
  end

  create_table "job_shared_tos", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "job_share_id", null: false
    t.integer "trainee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "job_share_id"], name: "index_job_shared_tos_on_account_id_and_job_share_id"
    t.index ["account_id", "trainee_id"], name: "index_job_shared_tos_on_account_id_and_trainee_id"
  end

  create_table "job_shares", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "title", limit: 255
    t.string "company", limit: 255
    t.string "date_posted", limit: 255
    t.text "excerpt"
    t.string "location", limit: 255
    t.string "source", limit: 255
    t.text "details_url"
    t.integer "details_url_type"
    t.string "comment", limit: 255
    t.integer "from_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_job_shares_on_account_id"
  end

  create_table "klass_categories", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "grant_id"
    t.string "code", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_klass_categories_on_account_id"
    t.index ["grant_id"], name: "index_klass_categories_on_grant_id"
  end

  create_table "klass_certificates", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "klass_id"
    t.string "name", limit: 255
    t.string "description", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "certificate_category_id"
    t.index ["account_id", "klass_id"], name: "index_klass_certificates_on_account_id_and_klass_id"
    t.index ["certificate_category_id"], name: "index_klass_certificates_on_certificate_category_id"
  end

  create_table "klass_events", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "klass_id"
    t.string "name", limit: 255
    t.date "event_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notes", limit: 255
    t.string "start_ampm", limit: 255
    t.integer "start_time_hr"
    t.integer "start_time_min"
    t.string "end_ampm", limit: 255
    t.integer "end_time_hr"
    t.integer "end_time_min"
    t.string "uid", limit: 255
    t.integer "sequence"
    t.index ["account_id", "klass_id"], name: "index_klass_events_on_account_id_and_klass_id"
  end

  create_table "klass_instructors", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "klass_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "klass_id"], name: "index_klass_instructors_on_account_id_and_klass_id"
    t.index ["account_id", "user_id"], name: "index_klass_instructors_on_account_id_and_user_id"
  end

  create_table "klass_interactions", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "grant_id", null: false
    t.integer "employer_id", null: false
    t.integer "klass_event_id", null: false
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "grant_id", "employer_id"], name: "klass_interactions_employer_id_index"
    t.index ["account_id", "grant_id", "klass_event_id"], name: "klass_interactions_klass_event_id_index"
  end

  create_table "klass_navigators", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "klass_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "klass_id"], name: "index_klass_navigators_on_account_id_and_klass_id"
    t.index ["account_id", "user_id"], name: "index_klass_navigators_on_account_id_and_user_id"
  end

  create_table "klass_schedules", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "klass_id"
    t.boolean "scheduled", default: false
    t.integer "dayoftheweek"
    t.integer "start_time_hr", default: 0
    t.integer "start_time_min", default: 0
    t.string "start_ampm", limit: 255, default: "am"
    t.integer "end_time_hr", default: 0
    t.integer "end_time_min", default: 0
    t.string "end_ampm", limit: 255, default: "pm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "klass_id"], name: "index_klass_schedules_on_account_id_and_klass_id"
  end

  create_table "klass_titles", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "klass_id", null: false
    t.string "title", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "klass_id"], name: "index_klass_titles_on_account_id_and_klass_id"
  end

  create_table "klass_trainees", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "klass_id", null: false
    t.integer "trainee_id", null: false
    t.integer "status", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notes", limit: 255
    t.index ["account_id", "klass_id"], name: "index_klass_trainees_on_account_id_and_klass_id"
    t.index ["account_id", "trainee_id"], name: "index_klass_trainees_on_account_id_and_trainee_id"
  end

  create_table "klasses", id: :serial, force: :cascade do |t|
    t.integer "college_id", null: false
    t.string "name", limit: 255, null: false
    t.string "description", limit: 255
    t.integer "training_hours"
    t.integer "credits"
    t.date "start_date"
    t.date "end_date"
    t.integer "program_id", null: false
    t.integer "account_id", null: false
    t.integer "grant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "klass_category_id"
    t.index ["account_id", "grant_id", "program_id"], name: "klasses_index"
    t.index ["klass_category_id"], name: "index_klasses_on_klass_category_id"
  end

  create_table "leads_queues", id: :serial, force: :cascade do |t|
    t.integer "trainee_id"
    t.integer "status", default: 0
    t.hstore "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trainee_id"], name: "index_leads_queues_on_trainee_id"
  end

  create_table "mentors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "opero_companies", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "phone", limit: 255
    t.string "source", limit: 255
    t.string "line1", limit: 255
    t.string "city", limit: 255
    t.string "state_code", limit: 255
    t.integer "state_id"
    t.integer "county_id"
    t.string "zip", limit: 255
    t.string "formatted_address", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "website", limit: 255
    t.index ["county_id"], name: "index_opero_companies_on_county_id"
    t.index ["state_id"], name: "index_opero_companies_on_state_id"
  end

  create_table "polygons", id: :serial, force: :cascade do |t|
    t.integer "mappable_id", null: false
    t.string "mappable_type", limit: 255, null: false
    t.text "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mappable_id", "mappable_type"], name: "index_polygons_on_mappable_id_and_mappable_type"
  end

  create_table "programs", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "description", limit: 255, null: false
    t.integer "hours"
    t.integer "sector_id"
    t.integer "grant_id", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "klass_category_id"
    t.index ["account_id", "grant_id"], name: "index_programs_on_account_id_and_grant_id"
    t.index ["klass_category_id"], name: "index_programs_on_klass_category_id"
  end

  create_table "races", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sectors", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shared_job_statuses", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "trainee_id"
    t.integer "shared_job_id"
    t.integer "status"
    t.string "feedback", limit: 255
    t.string "key", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_shared_job_statuses_on_account_id"
    t.index ["shared_job_id"], name: "index_shared_job_statuses_on_shared_job_id"
    t.index ["trainee_id"], name: "index_shared_job_statuses_on_trainee_id"
  end

  create_table "shared_jobs", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "details_url"
    t.text "excerpt"
    t.integer "job_share_id"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date_posted"
    t.index ["account_id"], name: "index_shared_jobs_on_account_id"
    t.index ["job_share_id"], name: "index_shared_jobs_on_job_share_id"
  end

  create_table "special_services", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "grant_id"
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_special_services_on_account_id"
    t.index ["grant_id"], name: "index_special_services_on_grant_id"
  end

  create_table "states", id: :serial, force: :cascade do |t|
    t.string "code", limit: 255, null: false
    t.string "name", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_states_on_code", unique: true
  end

  create_table "tact_threes", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "trainee_id", null: false
    t.integer "education_level"
    t.string "recent_employer", limit: 255
    t.string "job_title", limit: 255
    t.integer "years"
    t.text "certifications"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "current_employment_status"
    t.string "last_wages"
    t.date "last_employed_on"
    t.date "registration_date"
    t.index ["account_id", "trainee_id"], name: "index_tact_threes_on_account_id_and_trainee_id"
  end

  create_table "trainee_assessments", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "trainee_id", null: false
    t.integer "assessment_id", null: false
    t.string "score", limit: 255
    t.boolean "pass"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date"
    t.index ["account_id", "trainee_id"], name: "index_trainee_assessments_on_account_id_and_trainee_id"
  end

  create_table "trainee_auto_lead_statuses", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "grant_id"
    t.integer "trainee_id"
    t.boolean "viewed"
    t.boolean "applied"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_trainee_auto_lead_statuses_on_account_id"
    t.index ["grant_id"], name: "index_trainee_auto_lead_statuses_on_grant_id"
    t.index ["trainee_id"], name: "index_trainee_auto_lead_statuses_on_trainee_id"
  end

  create_table "trainee_emails", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "user_id"
    t.integer "klass_id"
    t.text "trainee_names"
    t.text "trainee_ids"
    t.string "subject", limit: 255
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_trainee_emails_on_account_id"
    t.index ["klass_id"], name: "index_trainee_emails_on_klass_id"
    t.index ["user_id"], name: "index_trainee_emails_on_user_id"
  end

  create_table "trainee_files", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "trainee_id", null: false
    t.string "file", limit: 255
    t.string "notes", limit: 255
    t.integer "uploaded_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "trainee_id"], name: "index_trainee_files_on_account_id_and_trainee_id"
  end

  create_table "trainee_interactions", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "grant_id", null: false
    t.integer "employer_id", null: false
    t.integer "trainee_id", null: false
    t.integer "status"
    t.string "hire_title", limit: 255
    t.string "hire_salary", limit: 255
    t.date "start_date"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "company", limit: 255
    t.date "termination_date"
    t.date "completion_date"
    t.string "uses_trained_skills"
    t.index ["account_id", "grant_id", "employer_id"], name: "trainee_interactions_employer_id_index"
    t.index ["account_id", "grant_id", "trainee_id"], name: "trainee_interactions_trainee_id_index"
  end

  create_table "trainee_notes", id: :serial, force: :cascade do |t|
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "trainee_id"
    t.index ["trainee_id"], name: "index_trainee_notes_on_trainee_id"
  end

  create_table "trainee_placements", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "trainee_id"
    t.hstore "info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_trainee_placements_on_account_id"
    t.index ["info"], name: "index_trainee_placements_on_info", using: :gin
    t.index ["trainee_id"], name: "index_trainee_placements_on_trainee_id"
  end

  create_table "trainee_races", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "trainee_id", null: false
    t.integer "race_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_trainee_races_on_account_id"
  end

  create_table "trainee_services", id: :serial, force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date"
    t.string "name", null: false
    t.integer "trainee_id"
    t.integer "account_id"
    t.integer "grant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "grant_id", "trainee_id"], name: "trainee_services_scope"
  end

  create_table "trainee_submits", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "trainee_id", null: false
    t.integer "employer_id", null: false
    t.string "title", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "applied_on"
    t.integer "email_id"
    t.index ["account_id", "employer_id"], name: "index_trainee_submits_on_account_id_and_employer_id"
    t.index ["account_id", "trainee_id"], name: "index_trainee_submits_on_account_id_and_trainee_id"
    t.index ["email_id"], name: "index_trainee_submits_on_email_id"
  end

  create_table "trainees", id: :serial, force: :cascade do |t|
    t.string "first", limit: 255
    t.string "middle", limit: 255
    t.string "last", limit: 255
    t.integer "status"
    t.string "trainee_id", limit: 255
    t.date "dob"
    t.string "gender", limit: 255
    t.string "disability", limit: 255
    t.boolean "veteran"
    t.string "education", limit: 255
    t.string "land_no", limit: 255
    t.string "mobile_no", limit: 255
    t.string "email", limit: 255, default: "", null: false
    t.string "skills_experience", limit: 255
    t.integer "account_id", null: false
    t.integer "grant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legal_status"
    t.integer "funding_source_id"
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "encrypted_trainee_id", limit: 255
    t.string "login_id", limit: 255
    t.integer "race_id"
    t.date "edp_date"
    t.date "disabled_date"
    t.string "disabled_notes"
    t.date "ui_claim_verified_on"
    t.string "employment_status"
    t.string "features", default: [], array: true
    t.boolean "bounced"
    t.string "bounced_reason"
    t.integer "mentor_id"
    t.integer "employer_id"
    t.index ["account_id", "grant_id"], name: "index_trainees_on_account_id_and_grant_id"
    t.index ["employer_id"], name: "index_trainees_on_employer_id"
    t.index ["login_id"], name: "index_trainees_on_login_id", unique: true
    t.index ["mentor_id"], name: "index_trainees_on_mentor_id"
  end

  create_table "ui_verified_notes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "notes"
    t.integer "trainee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trainee_id"], name: "index_ui_verified_notes_on_trainee_id"
    t.index ["user_id"], name: "index_ui_verified_notes_on_user_id"
  end

  create_table "unemployment_proofs", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "grant_id"
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_unemployment_proofs_on_account_id"
    t.index ["grant_id"], name: "index_unemployment_proofs_on_grant_id"
  end

  create_table "user_counties", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "user_id"
    t.integer "county_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_user_counties_on_account_id"
    t.index ["county_id"], name: "index_user_counties_on_county_id"
    t.index ["user_id"], name: "index_user_counties_on_user_id"
  end

  create_table "user_employer_sources", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "employer_source_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_user_employer_sources_on_account_id"
    t.index ["employer_source_id"], name: "index_user_employer_sources_on_employer_source_id"
    t.index ["user_id"], name: "index_user_employer_sources_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "first", limit: 255, null: false
    t.string "last", limit: 255, null: false
    t.string "location", limit: 255, null: false
    t.integer "role", null: false
    t.integer "status", null: false
    t.string "land_no", limit: 255
    t.string "ext", limit: 255
    t.string "mobile_no", limit: 255
    t.string "comments", limit: 255
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_activity_at"
    t.text "options"
    t.hstore "data"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "certificate_categories", "accounts"
  add_foreign_key "certificate_categories", "grants"
  add_foreign_key "grant_job_lead_counts", "accounts"
  add_foreign_key "grant_job_lead_counts", "grants"
  add_foreign_key "hot_jobs", "accounts"
  add_foreign_key "hot_jobs", "employers"
  add_foreign_key "hot_jobs", "users"
  add_foreign_key "klass_categories", "accounts"
  add_foreign_key "klass_categories", "grants"
  add_foreign_key "klass_certificates", "certificate_categories"
  add_foreign_key "klasses", "klass_categories"
  add_foreign_key "leads_queues", "trainees"
  add_foreign_key "programs", "klass_categories"
  add_foreign_key "trainee_auto_lead_statuses", "accounts"
  add_foreign_key "trainee_auto_lead_statuses", "grants"
  add_foreign_key "trainee_auto_lead_statuses", "trainees"
  add_foreign_key "trainee_services", "accounts"
  add_foreign_key "trainee_services", "grants"
  add_foreign_key "trainee_services", "trainees"
  add_foreign_key "trainees", "employers"
  add_foreign_key "ui_verified_notes", "trainees"
  add_foreign_key "ui_verified_notes", "users"
end
