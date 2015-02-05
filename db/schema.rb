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

ActiveRecord::Schema.define(version: 20150203192638) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "account_states", force: true do |t|
    t.integer  "account_id"
    t.integer  "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "account_states", ["account_id"], name: "index_account_states_on_account_id", using: :btree
  add_index "account_states", ["state_id"], name: "index_account_states_on_state_id", using: :btree

  create_table "accounts", force: true do |t|
    t.string   "name",        null: false
    t.string   "description", null: false
    t.integer  "client_type", null: false
    t.integer  "status",      null: false
    t.string   "subdomain",   null: false
    t.string   "logo_file"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "options"
  end

  create_table "addresses", force: true do |t|
    t.string   "line1"
    t.string   "line2"
    t.string   "city",             limit: 30, null: false
    t.string   "county"
    t.string   "state",            limit: 2,  null: false
    t.string   "zip",              limit: 10, null: false
    t.string   "country"
    t.integer  "account_id",                  null: false
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.string   "type"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "county_id"
  end

  add_index "addresses", ["account_id", "addressable_id", "addressable_type"], name: "addresses_index", using: :btree
  add_index "addresses", ["account_id"], name: "index_addresses_on_account_id", using: :btree

  create_table "admins", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "agents", force: true do |t|
    t.hstore   "info"
    t.integer  "identifiable_id"
    t.string   "identifiable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agents", ["identifiable_id", "identifiable_type"], name: "index_agents_on_identifiable_id_and_identifiable_type", using: :btree

  create_table "applicant_reapplies", force: true do |t|
    t.integer  "applicant_id"
    t.integer  "account_id"
    t.integer  "grant_id"
    t.string   "key"
    t.boolean  "used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "applicant_reapplies", ["account_id"], name: "index_applicant_reapplies_on_account_id", using: :btree
  add_index "applicant_reapplies", ["applicant_id"], name: "index_applicant_reapplies_on_applicant_id", using: :btree
  add_index "applicant_reapplies", ["grant_id"], name: "index_applicant_reapplies_on_grant_id", using: :btree

  create_table "applicant_sources", force: true do |t|
    t.string   "source"
    t.integer  "account_id"
    t.integer  "grant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "applicant_sources", ["account_id"], name: "index_applicant_sources_on_account_id", using: :btree
  add_index "applicant_sources", ["grant_id"], name: "index_applicant_sources_on_grant_id", using: :btree

  create_table "applicant_special_services", force: true do |t|
    t.integer  "account_id"
    t.integer  "grant_id"
    t.integer  "special_service_id"
    t.integer  "applicant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "applicant_special_services", ["account_id"], name: "index_applicant_special_services_on_account_id", using: :btree
  add_index "applicant_special_services", ["applicant_id"], name: "index_applicant_special_services_on_applicant_id", using: :btree
  add_index "applicant_special_services", ["grant_id"], name: "index_applicant_special_services_on_grant_id", using: :btree
  add_index "applicant_special_services", ["special_service_id"], name: "index_applicant_special_services_on_special_service_id", using: :btree

  create_table "applicant_unemployment_proofs", force: true do |t|
    t.integer  "account_id"
    t.integer  "grant_id"
    t.integer  "unemployment_proof_id"
    t.integer  "applicant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "applicant_unemployment_proofs", ["account_id"], name: "index_applicant_unemployment_proofs_on_account_id", using: :btree
  add_index "applicant_unemployment_proofs", ["applicant_id"], name: "index_applicant_unemployment_proofs_on_applicant_id", using: :btree
  add_index "applicant_unemployment_proofs", ["grant_id"], name: "index_applicant_unemployment_proofs_on_grant_id", using: :btree
  add_index "applicant_unemployment_proofs", ["unemployment_proof_id"], name: "index_applicant_unemployment_proofs_on_unemployment_proof_id", using: :btree

  create_table "applicants", force: true do |t|
    t.integer  "account_id",                     null: false
    t.integer  "grant_id",                       null: false
    t.integer  "trainee_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_zip"
    t.string   "email"
    t.string   "mobile_phone_no"
    t.date     "last_employed_on"
    t.string   "current_employment_status"
    t.string   "last_job_title"
    t.string   "salary_expected"
    t.string   "education_level"
    t.boolean  "transportation"
    t.boolean  "computer_access"
    t.text     "resume"
    t.boolean  "signature"
    t.text     "comments"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "county_id"
    t.integer  "legal_status"
    t.boolean  "veteran"
    t.string   "last_employer_name"
    t.string   "last_employer_city"
    t.string   "last_employer_state"
    t.integer  "navigator_id"
    t.integer  "sector_id"
    t.string   "gender"
    t.string   "last_employer_manager_name"
    t.string   "last_employer_manager_phone_no"
    t.string   "last_employer_manager_email"
    t.string   "last_employer_line1"
    t.string   "last_employer_line2"
    t.string   "last_employer_zip"
    t.string   "last_wages"
    t.integer  "race_id"
    t.string   "source"
    t.string   "unemployment_proof"
  end

  add_index "applicants", ["account_id"], name: "index_applicants_on_account_id", using: :btree
  add_index "applicants", ["email"], name: "index_applicants_on_email", unique: true, using: :btree
  add_index "applicants", ["grant_id"], name: "index_applicants_on_grant_id", using: :btree
  add_index "applicants", ["race_id"], name: "index_applicants_on_race_id", using: :btree
  add_index "applicants", ["trainee_id"], name: "index_applicants_on_trainee_id", using: :btree

  create_table "assessments", force: true do |t|
    t.integer  "account_id",      null: false
    t.string   "name"
    t.integer  "administered_by"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "grant_id"
  end

  add_index "assessments", ["account_id"], name: "index_assessments_on_account_id", using: :btree
  add_index "assessments", ["grant_id"], name: "index_assessments_on_grant_id", using: :btree

  create_table "attachments", force: true do |t|
    t.integer  "account_id"
    t.integer  "email_id"
    t.string   "name"
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["account_id"], name: "index_attachments_on_account_id", using: :btree
  add_index "attachments", ["email_id"], name: "index_attachments_on_email_id", using: :btree

  create_table "auto_lead_email_texts", force: true do |t|
    t.string   "type"
    t.text     "content"
    t.integer  "account_id"
    t.integer  "grant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auto_lead_email_texts", ["account_id"], name: "index_auto_lead_email_texts_on_account_id", using: :btree
  add_index "auto_lead_email_texts", ["grant_id"], name: "index_auto_lead_email_texts_on_grant_id", using: :btree

  create_table "auto_shared_jobs", force: true do |t|
    t.integer  "account_id"
    t.integer  "trainee_id"
    t.string   "title"
    t.string   "company"
    t.datetime "date_posted"
    t.string   "location"
    t.text     "excerpt"
    t.text     "url"
    t.integer  "status"
    t.text     "feedback"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.date     "notes_updated_at"
    t.date     "status_updated_at"
  end

  add_index "auto_shared_jobs", ["trainee_id"], name: "index_auto_shared_jobs_on_trainee_id", using: :btree

  create_table "cities", force: true do |t|
    t.integer  "state_id",   null: false
    t.string   "state_code", null: false
    t.string   "zip"
    t.string   "city_state", null: false
    t.integer  "county_id",  null: false
    t.string   "name",       null: false
    t.float    "longitude",  null: false
    t.float    "latitude",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "cities", ["city_state"], name: "index_cities_on_city_state", using: :btree
  add_index "cities", ["state_id"], name: "index_cities_on_state_id", using: :btree

  create_table "colleges", force: true do |t|
    t.string   "name"
    t.integer  "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "colleges", ["account_id"], name: "index_colleges_on_account_id", using: :btree

  create_table "contact_emails", force: true do |t|
    t.integer  "account_id"
    t.integer  "email_id"
    t.integer  "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "contact_emails", ["account_id"], name: "index_contact_emails_on_account_id", using: :btree
  add_index "contact_emails", ["contact_id"], name: "index_contact_emails_on_contact_id", using: :btree
  add_index "contact_emails", ["email_id"], name: "index_contact_emails_on_email_id", using: :btree

  create_table "contacts", force: true do |t|
    t.integer  "contactable_id"
    t.string   "contactable_type"
    t.string   "first"
    t.string   "last"
    t.string   "title"
    t.string   "land_no"
    t.string   "ext"
    t.string   "mobile_no"
    t.string   "email"
    t.integer  "account_id",       null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "contacts", ["account_id", "contactable_type", "contactable_id"], name: "contacts_index", using: :btree

  create_table "counties", force: true do |t|
    t.integer  "state_id",   null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "counties", ["state_id"], name: "index_counties_on_state_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "educations", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "position"
  end

  create_table "emails", force: true do |t|
    t.integer  "account_id"
    t.string   "subject"
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.text     "trainee_file_ids"
  end

  add_index "emails", ["account_id"], name: "index_emails_on_account_id", using: :btree
  add_index "emails", ["user_id"], name: "index_emails_on_user_id", using: :btree

  create_table "employer_notes", force: true do |t|
    t.integer  "employer_id", null: false
    t.integer  "account_id",  null: false
    t.text     "note",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "employer_notes", ["account_id", "employer_id"], name: "index_employer_notes_on_account_id_and_employer_id", using: :btree

  create_table "employer_sectors", force: true do |t|
    t.integer  "account_id",  null: false
    t.integer  "employer_id", null: false
    t.integer  "sector_id",   null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "employer_sectors", ["account_id", "employer_id"], name: "index_employer_sectors_on_account_id_and_employer_id", using: :btree
  add_index "employer_sectors", ["account_id", "sector_id"], name: "index_employer_sectors_on_account_id_and_sector_id", using: :btree

  create_table "employers", force: true do |t|
    t.string   "name"
    t.string   "source"
    t.integer  "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "phone_no"
    t.string   "website"
  end

  add_index "employers", ["account_id", "source"], name: "index_employers_on_account_id_and_source", using: :btree
  add_index "employers", ["account_id"], name: "index_employers_on_account_id", using: :btree

  create_table "employment_statuses", force: true do |t|
    t.string   "status"
    t.integer  "grant_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action"
    t.string   "email_subject"
    t.text     "email_body"
  end

  add_index "employment_statuses", ["account_id"], name: "index_employment_statuses_on_account_id", using: :btree
  add_index "employment_statuses", ["grant_id"], name: "index_employment_statuses_on_grant_id", using: :btree

  create_table "funding_sources", force: true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "grant_id"
  end

  add_index "funding_sources", ["account_id"], name: "index_funding_sources_on_account_id", using: :btree

  create_table "google_places_searches", force: true do |t|
    t.string   "name"
    t.integer  "city_id"
    t.float    "score"
    t.integer  "opero_company_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "google_places_searches", ["name", "city_id"], name: "index_google_places_searches_on_name_and_city_id", using: :btree
  add_index "google_places_searches", ["opero_company_id"], name: "index_google_places_searches_on_opero_company_id", using: :btree

  create_table "grant_admins", force: true do |t|
    t.integer  "account_id"
    t.integer  "grant_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grant_admins", ["account_id"], name: "index_klass_admins_on_account_id", using: :btree
  add_index "grant_admins", ["grant_id"], name: "index_klass_admins_on_grant_id", using: :btree
  add_index "grant_admins", ["user_id"], name: "index_klass_admins_on_user_id", using: :btree

  create_table "grants", force: true do |t|
    t.string   "name",          null: false
    t.date     "start_date",    null: false
    t.date     "end_date",      null: false
    t.integer  "status",        null: false
    t.integer  "spots"
    t.integer  "amount"
    t.integer  "account_id",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.text     "options"
    t.hstore   "specific_data"
  end

  add_index "grants", ["account_id"], name: "index_grants_on_account_id", using: :btree

  create_table "import_fails", force: true do |t|
    t.integer  "account_id"
    t.integer  "import_status_id"
    t.text     "row_data"
    t.string   "error_message"
    t.boolean  "can_retry"
    t.boolean  "geocoder_fail"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "row_no"
  end

  add_index "import_fails", ["account_id"], name: "index_import_fails_on_account_id", using: :btree
  add_index "import_fails", ["import_status_id"], name: "index_import_fails_on_import_status_id", using: :btree

  create_table "import_statuses", force: true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.string   "file_name"
    t.string   "type"
    t.integer  "rows_successful"
    t.integer  "rows_failed"
    t.string   "sector_ids"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "klass_id"
    t.text     "params"
    t.string   "status"
    t.text     "data"
    t.text     "aws_file_name"
  end

  add_index "import_statuses", ["account_id"], name: "index_import_statuses_on_account_id", using: :btree

  create_table "job_openings", force: true do |t|
    t.integer  "jobs_no"
    t.string   "skills"
    t.integer  "employer_id", null: false
    t.integer  "account_id",  null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "job_openings", ["account_id", "employer_id"], name: "index_job_openings_on_account_id_and_employer_id", using: :btree

  create_table "job_search_profiles", force: true do |t|
    t.integer  "account_id"
    t.integer  "trainee_id"
    t.text     "skills"
    t.string   "location"
    t.integer  "distance"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "opted_out"
    t.string   "opt_out_reason"
    t.string   "company_name"
    t.string   "title"
    t.string   "salary"
    t.string   "zip"
    t.date     "start_date"
    t.integer  "opt_out_reason_code"
  end

  add_index "job_search_profiles", ["account_id"], name: "index_job_search_profiles_on_account_id", using: :btree
  add_index "job_search_profiles", ["trainee_id"], name: "index_job_search_profiles_on_trainee_id", using: :btree

  create_table "job_searches", force: true do |t|
    t.string   "keywords"
    t.string   "location"
    t.integer  "user_id"
    t.integer  "account_id",     null: false
    t.integer  "distance"
    t.integer  "recruiters"
    t.integer  "days"
    t.integer  "klass_title_id"
    t.integer  "count"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "in_state"
  end

  add_index "job_searches", ["account_id", "user_id"], name: "index_job_searches_on_account_id_and_user_id", using: :btree
  add_index "job_searches", ["account_id"], name: "index_job_searches_on_account_id", using: :btree

  create_table "job_shared_tos", force: true do |t|
    t.integer  "account_id",   null: false
    t.integer  "job_share_id", null: false
    t.integer  "trainee_id",   null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "job_shared_tos", ["account_id", "job_share_id"], name: "index_job_shared_tos_on_account_id_and_job_share_id", using: :btree
  add_index "job_shared_tos", ["account_id", "trainee_id"], name: "index_job_shared_tos_on_account_id_and_trainee_id", using: :btree

  create_table "job_shares", force: true do |t|
    t.integer  "account_id",       null: false
    t.string   "title"
    t.string   "company"
    t.string   "date_posted"
    t.text     "excerpt"
    t.string   "location"
    t.string   "source"
    t.text     "details_url"
    t.integer  "details_url_type"
    t.string   "comment"
    t.integer  "from_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "job_shares", ["account_id"], name: "index_job_shares_on_account_id", using: :btree

  create_table "klass_certificates", force: true do |t|
    t.integer  "account_id",  null: false
    t.integer  "klass_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "klass_certificates", ["account_id", "klass_id"], name: "index_klass_certificates_on_account_id_and_klass_id", using: :btree

  create_table "klass_events", force: true do |t|
    t.integer  "account_id",     null: false
    t.integer  "klass_id"
    t.string   "name"
    t.date     "event_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "notes"
    t.string   "start_ampm"
    t.integer  "start_time_hr"
    t.integer  "start_time_min"
    t.string   "end_ampm"
    t.integer  "end_time_hr"
    t.integer  "end_time_min"
    t.string   "uid"
    t.integer  "sequence"
  end

  add_index "klass_events", ["account_id", "klass_id"], name: "index_klass_events_on_account_id_and_klass_id", using: :btree

  create_table "klass_instructors", force: true do |t|
    t.integer  "account_id", null: false
    t.integer  "klass_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "klass_instructors", ["account_id", "klass_id"], name: "index_klass_instructors_on_account_id_and_klass_id", using: :btree
  add_index "klass_instructors", ["account_id", "user_id"], name: "index_klass_instructors_on_account_id_and_user_id", using: :btree

  create_table "klass_interactions", force: true do |t|
    t.integer  "account_id",     null: false
    t.integer  "grant_id",       null: false
    t.integer  "employer_id",    null: false
    t.integer  "klass_event_id", null: false
    t.integer  "status"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "klass_interactions", ["account_id", "grant_id", "employer_id"], name: "klass_interactions_employer_id_index", using: :btree
  add_index "klass_interactions", ["account_id", "grant_id", "klass_event_id"], name: "klass_interactions_klass_event_id_index", using: :btree

  create_table "klass_navigators", force: true do |t|
    t.integer  "account_id", null: false
    t.integer  "klass_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "klass_navigators", ["account_id", "klass_id"], name: "index_klass_navigators_on_account_id_and_klass_id", using: :btree
  add_index "klass_navigators", ["account_id", "user_id"], name: "index_klass_navigators_on_account_id_and_user_id", using: :btree

  create_table "klass_schedules", force: true do |t|
    t.integer  "account_id",                     null: false
    t.integer  "klass_id"
    t.boolean  "scheduled",      default: false
    t.integer  "dayoftheweek"
    t.integer  "start_time_hr",  default: 0
    t.integer  "start_time_min", default: 0
    t.string   "start_ampm",     default: "am"
    t.integer  "end_time_hr",    default: 0
    t.integer  "end_time_min",   default: 0
    t.string   "end_ampm",       default: "pm"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "klass_schedules", ["account_id", "klass_id"], name: "index_klass_schedules_on_account_id_and_klass_id", using: :btree

  create_table "klass_titles", force: true do |t|
    t.integer  "account_id", null: false
    t.integer  "klass_id",   null: false
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "klass_titles", ["account_id", "klass_id"], name: "index_klass_titles_on_account_id_and_klass_id", using: :btree

  create_table "klass_trainees", force: true do |t|
    t.integer  "account_id",             null: false
    t.integer  "klass_id",               null: false
    t.integer  "trainee_id",             null: false
    t.integer  "status",     default: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "notes"
  end

  add_index "klass_trainees", ["account_id", "klass_id"], name: "index_klass_trainees_on_account_id_and_klass_id", using: :btree
  add_index "klass_trainees", ["account_id", "trainee_id"], name: "index_klass_trainees_on_account_id_and_trainee_id", using: :btree

  create_table "klasses", force: true do |t|
    t.integer  "college_id",     null: false
    t.string   "name",           null: false
    t.string   "description"
    t.integer  "training_hours"
    t.integer  "credits"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "program_id",     null: false
    t.integer  "account_id",     null: false
    t.integer  "grant_id",       null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "klasses", ["account_id", "grant_id", "program_id"], name: "klasses_index", using: :btree

  create_table "opero_companies", force: true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "source"
    t.string   "line1"
    t.string   "city"
    t.string   "state_code"
    t.integer  "state_id"
    t.integer  "county_id"
    t.string   "zip"
    t.string   "formatted_address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "website"
  end

  add_index "opero_companies", ["county_id"], name: "index_opero_companies_on_county_id", using: :btree
  add_index "opero_companies", ["state_id"], name: "index_opero_companies_on_state_id", using: :btree

  create_table "polygons", force: true do |t|
    t.integer  "mappable_id",   null: false
    t.string   "mappable_type", null: false
    t.text     "json"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "polygons", ["mappable_id", "mappable_type"], name: "index_polygons_on_mappable_id_and_mappable_type", using: :btree

  create_table "programs", force: true do |t|
    t.string   "name",        null: false
    t.string   "description", null: false
    t.integer  "hours"
    t.integer  "sector_id"
    t.integer  "grant_id",    null: false
    t.integer  "account_id",  null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "programs", ["account_id", "grant_id"], name: "index_programs_on_account_id_and_grant_id", using: :btree

  create_table "races", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sectors", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shared_job_statuses", force: true do |t|
    t.integer  "account_id"
    t.integer  "trainee_id"
    t.integer  "shared_job_id"
    t.integer  "status"
    t.string   "feedback"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shared_job_statuses", ["account_id"], name: "index_shared_job_statuses_on_account_id", using: :btree
  add_index "shared_job_statuses", ["shared_job_id"], name: "index_shared_job_statuses_on_shared_job_id", using: :btree
  add_index "shared_job_statuses", ["trainee_id"], name: "index_shared_job_statuses_on_trainee_id", using: :btree

  create_table "shared_jobs", force: true do |t|
    t.string   "title"
    t.text     "details_url"
    t.text     "excerpt"
    t.integer  "job_share_id"
    t.integer  "account_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "date_posted"
  end

  add_index "shared_jobs", ["account_id"], name: "index_shared_jobs_on_account_id", using: :btree
  add_index "shared_jobs", ["job_share_id"], name: "index_shared_jobs_on_job_share_id", using: :btree

  create_table "special_services", force: true do |t|
    t.integer  "account_id"
    t.integer  "grant_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "special_services", ["account_id"], name: "index_special_services_on_account_id", using: :btree
  add_index "special_services", ["grant_id"], name: "index_special_services_on_grant_id", using: :btree

  create_table "states", force: true do |t|
    t.string   "code",       null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "states", ["code"], name: "index_states_on_code", unique: true, using: :btree

  create_table "tact_threes", force: true do |t|
    t.integer  "account_id",      null: false
    t.integer  "trainee_id",      null: false
    t.integer  "education_level"
    t.string   "recent_employer"
    t.string   "job_title"
    t.integer  "years"
    t.text     "certifications"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "tact_threes", ["account_id", "trainee_id"], name: "index_tact_threes_on_account_id_and_trainee_id", using: :btree

  create_table "trainee_assessments", force: true do |t|
    t.integer  "account_id",    null: false
    t.integer  "trainee_id",    null: false
    t.integer  "assessment_id", null: false
    t.string   "score"
    t.boolean  "pass"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "trainee_assessments", ["account_id", "trainee_id"], name: "index_trainee_assessments_on_account_id_and_trainee_id", using: :btree

  create_table "trainee_emails", force: true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.integer  "klass_id"
    t.text     "trainee_names"
    t.text     "trainee_ids"
    t.string   "subject"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trainee_emails", ["account_id"], name: "index_trainee_emails_on_account_id", using: :btree
  add_index "trainee_emails", ["klass_id"], name: "index_trainee_emails_on_klass_id", using: :btree
  add_index "trainee_emails", ["user_id"], name: "index_trainee_emails_on_user_id", using: :btree

  create_table "trainee_files", force: true do |t|
    t.integer  "account_id",  null: false
    t.integer  "trainee_id",  null: false
    t.string   "file"
    t.string   "notes"
    t.integer  "uploaded_by"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "trainee_files", ["account_id", "trainee_id"], name: "index_trainee_files_on_account_id_and_trainee_id", using: :btree

  create_table "trainee_interactions", force: true do |t|
    t.integer  "account_id",     null: false
    t.integer  "grant_id",       null: false
    t.integer  "employer_id",    null: false
    t.integer  "trainee_id",     null: false
    t.integer  "status"
    t.date     "interview_date"
    t.string   "interviewer"
    t.string   "hire_title"
    t.string   "hire_salary"
    t.date     "offer_date"
    t.date     "start_date"
    t.string   "offer_title"
    t.string   "offer_salary"
    t.text     "comment"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "company"
  end

  add_index "trainee_interactions", ["account_id", "grant_id", "employer_id"], name: "trainee_interactions_employer_id_index", using: :btree
  add_index "trainee_interactions", ["account_id", "grant_id", "trainee_id"], name: "trainee_interactions_trainee_id_index", using: :btree

  create_table "trainee_notes", force: true do |t|
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "trainee_id"
  end

  add_index "trainee_notes", ["trainee_id"], name: "index_trainee_notes_on_trainee_id", using: :btree

  create_table "trainee_placements", force: true do |t|
    t.integer  "account_id"
    t.integer  "trainee_id"
    t.hstore   "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trainee_placements", ["account_id"], name: "index_trainee_placements_on_account_id", using: :btree
  add_index "trainee_placements", ["info"], name: "index_trainee_placements_on_info", using: :gin
  add_index "trainee_placements", ["trainee_id"], name: "index_trainee_placements_on_trainee_id", using: :btree

  create_table "trainee_races", force: true do |t|
    t.integer  "account_id", null: false
    t.integer  "trainee_id", null: false
    t.integer  "race_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "trainee_races", ["account_id"], name: "index_trainee_races_on_account_id", using: :btree

  create_table "trainee_submits", force: true do |t|
    t.integer  "account_id",  null: false
    t.integer  "trainee_id",  null: false
    t.integer  "employer_id", null: false
    t.string   "title"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.date     "applied_on"
    t.integer  "email_id"
  end

  add_index "trainee_submits", ["account_id", "employer_id"], name: "index_trainee_submits_on_account_id_and_employer_id", using: :btree
  add_index "trainee_submits", ["account_id", "trainee_id"], name: "index_trainee_submits_on_account_id_and_trainee_id", using: :btree
  add_index "trainee_submits", ["email_id"], name: "index_trainee_submits_on_email_id", using: :btree

  create_table "trainees", force: true do |t|
    t.string   "first"
    t.string   "middle"
    t.string   "last"
    t.integer  "status"
    t.string   "trainee_id"
    t.date     "dob"
    t.string   "gender"
    t.string   "disability"
    t.boolean  "veteran"
    t.string   "education"
    t.string   "land_no"
    t.string   "mobile_no"
    t.string   "email",                  default: "", null: false
    t.string   "skills_experience"
    t.integer  "account_id",                          null: false
    t.integer  "grant_id",                            null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "legal_status"
    t.integer  "funding_source_id"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "encrypted_trainee_id"
    t.string   "login_id"
  end

  add_index "trainees", ["account_id", "grant_id"], name: "index_trainees_on_account_id_and_grant_id", using: :btree
  add_index "trainees", ["login_id"], name: "index_trainees_on_login_id", unique: true, using: :btree

  create_table "unemployment_proofs", force: true do |t|
    t.integer  "account_id"
    t.integer  "grant_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unemployment_proofs", ["account_id"], name: "index_unemployment_proofs_on_account_id", using: :btree
  add_index "unemployment_proofs", ["grant_id"], name: "index_unemployment_proofs_on_grant_id", using: :btree

  create_table "user_counties", force: true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.integer  "county_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_counties", ["account_id"], name: "index_user_counties_on_account_id", using: :btree
  add_index "user_counties", ["county_id"], name: "index_user_counties_on_county_id", using: :btree
  add_index "user_counties", ["user_id"], name: "index_user_counties_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "first",                               null: false
    t.string   "last",                                null: false
    t.string   "location",                            null: false
    t.integer  "role",                                null: false
    t.integer  "status",                              null: false
    t.string   "land_no"
    t.string   "ext"
    t.string   "mobile_no"
    t.string   "comments"
    t.integer  "account_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.datetime "last_activity_at"
    t.text     "options"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
