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

ActiveRecord::Schema.define(version: 20150215020529) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "account_states", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "account_states", ["account_id"], name: "index_account_states_on_account_id", using: :btree
  add_index "account_states", ["state_id"], name: "index_account_states_on_state_id", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "description", limit: 255, null: false
    t.integer  "client_type",             null: false
    t.integer  "status",                  null: false
    t.string   "subdomain",   limit: 255, null: false
    t.string   "logo_file",   limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.text     "options"
  end

  create_table "addresses", force: :cascade do |t|
    t.string   "line1",            limit: 255
    t.string   "line2",            limit: 255
    t.string   "city",             limit: 30,  null: false
    t.string   "county",           limit: 255
    t.string   "state",            limit: 2,   null: false
    t.string   "zip",              limit: 10,  null: false
    t.string   "country",          limit: 255
    t.integer  "account_id",                   null: false
    t.integer  "addressable_id"
    t.string   "addressable_type", limit: 255
    t.string   "type",             limit: 255
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "county_id"
  end

  add_index "addresses", ["account_id", "addressable_id", "addressable_type"], name: "addresses_index", using: :btree
  add_index "addresses", ["account_id"], name: "index_addresses_on_account_id", using: :btree

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "agents", force: :cascade do |t|
    t.hstore   "info"
    t.integer  "identifiable_id"
    t.string   "identifiable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agents", ["identifiable_id", "identifiable_type"], name: "index_agents_on_identifiable_id_and_identifiable_type", using: :btree

  create_table "applicant_reapplies", force: :cascade do |t|
    t.integer  "applicant_id"
    t.integer  "account_id"
    t.integer  "grant_id"
    t.string   "key",          limit: 255
    t.boolean  "used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "applicant_reapplies", ["account_id"], name: "index_applicant_reapplies_on_account_id", using: :btree
  add_index "applicant_reapplies", ["applicant_id"], name: "index_applicant_reapplies_on_applicant_id", using: :btree
  add_index "applicant_reapplies", ["grant_id"], name: "index_applicant_reapplies_on_grant_id", using: :btree

  create_table "applicant_sources", force: :cascade do |t|
    t.string   "source",     limit: 255
    t.integer  "account_id"
    t.integer  "grant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "applicant_sources", ["account_id"], name: "index_applicant_sources_on_account_id", using: :btree
  add_index "applicant_sources", ["grant_id"], name: "index_applicant_sources_on_grant_id", using: :btree

  create_table "applicant_special_services", force: :cascade do |t|
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

  create_table "applicant_unemployment_proofs", force: :cascade do |t|
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

  create_table "applicants", force: :cascade do |t|
    t.integer  "account_id",                                 null: false
    t.integer  "grant_id",                                   null: false
    t.integer  "trainee_id"
    t.string   "first_name",                     limit: 255
    t.string   "last_name",                      limit: 255
    t.string   "address_line1",                  limit: 255
    t.string   "address_line2",                  limit: 255
    t.string   "address_city",                   limit: 255
    t.string   "address_state",                  limit: 255
    t.string   "address_zip",                    limit: 255
    t.string   "email",                          limit: 255
    t.string   "mobile_phone_no",                limit: 255
    t.date     "last_employed_on"
    t.string   "current_employment_status",      limit: 255
    t.string   "last_job_title",                 limit: 255
    t.string   "salary_expected",                limit: 255
    t.string   "education_level",                limit: 255
    t.boolean  "transportation"
    t.boolean  "computer_access"
    t.text     "resume"
    t.boolean  "signature"
    t.text     "comments"
    t.string   "status",                         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "county_id"
    t.integer  "legal_status"
    t.boolean  "veteran"
    t.string   "last_employer_name",             limit: 255
    t.string   "last_employer_city",             limit: 255
    t.string   "last_employer_state",            limit: 255
    t.integer  "navigator_id"
    t.integer  "sector_id"
    t.string   "gender",                         limit: 255
    t.string   "last_employer_manager_name",     limit: 255
    t.string   "last_employer_manager_phone_no", limit: 255
    t.string   "last_employer_manager_email",    limit: 255
    t.string   "last_employer_line1",            limit: 255
    t.string   "last_employer_line2",            limit: 255
    t.string   "last_employer_zip",              limit: 255
    t.string   "last_wages",                     limit: 255
    t.integer  "race_id"
    t.string   "source",                         limit: 255
    t.string   "unemployment_proof",             limit: 255
    t.date     "applied_on"
  end

  add_index "applicants", ["account_id"], name: "index_applicants_on_account_id", using: :btree
  add_index "applicants", ["email"], name: "index_applicants_on_email", unique: true, using: :btree
  add_index "applicants", ["grant_id"], name: "index_applicants_on_grant_id", using: :btree
  add_index "applicants", ["race_id"], name: "index_applicants_on_race_id", using: :btree
  add_index "applicants", ["trainee_id"], name: "index_applicants_on_trainee_id", using: :btree

  create_table "assessments", force: :cascade do |t|
    t.integer  "account_id",                  null: false
    t.string   "name",            limit: 255
    t.integer  "administered_by"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "grant_id"
  end

  add_index "assessments", ["account_id"], name: "index_assessments_on_account_id", using: :btree
  add_index "assessments", ["grant_id"], name: "index_assessments_on_grant_id", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "email_id"
    t.string   "name",       limit: 255
    t.string   "file",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["account_id"], name: "index_attachments_on_account_id", using: :btree
  add_index "attachments", ["email_id"], name: "index_attachments_on_email_id", using: :btree

  create_table "auto_lead_email_texts", force: :cascade do |t|
    t.string   "type",       limit: 255
    t.text     "content"
    t.integer  "account_id"
    t.integer  "grant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auto_lead_email_texts", ["account_id"], name: "index_auto_lead_email_texts_on_account_id", using: :btree
  add_index "auto_lead_email_texts", ["grant_id"], name: "index_auto_lead_email_texts_on_grant_id", using: :btree

  create_table "auto_shared_jobs", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "trainee_id"
    t.string   "title",             limit: 255
    t.string   "company",           limit: 255
    t.datetime "date_posted"
    t.string   "location",          limit: 255
    t.text     "excerpt"
    t.text     "url"
    t.integer  "status"
    t.text     "feedback"
    t.string   "key",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.date     "notes_updated_at"
    t.date     "status_updated_at"
  end

  add_index "auto_shared_jobs", ["trainee_id"], name: "index_auto_shared_jobs_on_trainee_id", using: :btree

  create_table "cities", force: :cascade do |t|
    t.integer  "state_id",               null: false
    t.string   "state_code", limit: 255, null: false
    t.string   "zip",        limit: 255
    t.string   "city_state", limit: 255, null: false
    t.integer  "county_id",              null: false
    t.string   "name",       limit: 255, null: false
    t.float    "longitude",              null: false
    t.float    "latitude",               null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "cities", ["city_state"], name: "index_cities_on_city_state", using: :btree
  add_index "cities", ["state_id"], name: "index_cities_on_state_id", using: :btree

  create_table "colleges", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "account_id",             null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "colleges", ["account_id"], name: "index_colleges_on_account_id", using: :btree

  create_table "contact_emails", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "email_id"
    t.integer  "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "contact_emails", ["account_id"], name: "index_contact_emails_on_account_id", using: :btree
  add_index "contact_emails", ["contact_id"], name: "index_contact_emails_on_contact_id", using: :btree
  add_index "contact_emails", ["email_id"], name: "index_contact_emails_on_email_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.integer  "contactable_id"
    t.string   "contactable_type", limit: 255
    t.string   "first",            limit: 255
    t.string   "last",             limit: 255
    t.string   "title",            limit: 255
    t.string   "land_no",          limit: 255
    t.string   "ext",              limit: 255
    t.string   "mobile_no",        limit: 255
    t.string   "email",            limit: 255
    t.integer  "account_id",                   null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "contacts", ["account_id", "contactable_type", "contactable_id"], name: "contacts_index", using: :btree

  create_table "counties", force: :cascade do |t|
    t.integer  "state_id",               null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "counties", ["state_id"], name: "index_counties_on_state_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "educations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "position"
  end

  create_table "emails", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "subject",          limit: 255
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "trainee_file_ids"
  end

  add_index "emails", ["account_id"], name: "index_emails_on_account_id", using: :btree
  add_index "emails", ["user_id"], name: "index_emails_on_user_id", using: :btree

  create_table "employer_files", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "employer_id"
    t.string   "file"
    t.integer  "user_id"
    t.string   "notes"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "employer_files", ["account_id"], name: "index_employer_files_on_account_id", using: :btree
  add_index "employer_files", ["employer_id"], name: "index_employer_files_on_employer_id", using: :btree
  add_index "employer_files", ["user_id"], name: "index_employer_files_on_user_id", using: :btree

  create_table "employer_notes", force: :cascade do |t|
    t.integer  "employer_id", null: false
    t.integer  "account_id",  null: false
    t.text     "note",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "employer_notes", ["account_id", "employer_id"], name: "index_employer_notes_on_account_id_and_employer_id", using: :btree

  create_table "employer_sectors", force: :cascade do |t|
    t.integer  "account_id",  null: false
    t.integer  "employer_id", null: false
    t.integer  "sector_id",   null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "employer_sectors", ["account_id", "employer_id"], name: "index_employer_sectors_on_account_id_and_employer_id", using: :btree
  add_index "employer_sectors", ["account_id", "sector_id"], name: "index_employer_sectors_on_account_id_and_sector_id", using: :btree

  create_table "employers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "source",     limit: 255
    t.integer  "account_id",             null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "phone_no",   limit: 255
    t.string   "website",    limit: 255
  end

  add_index "employers", ["account_id", "source"], name: "index_employers_on_account_id_and_source", using: :btree
  add_index "employers", ["account_id"], name: "index_employers_on_account_id", using: :btree

  create_table "employment_statuses", force: :cascade do |t|
    t.string   "status",        limit: 255
    t.integer  "grant_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action",        limit: 255
    t.string   "email_subject", limit: 255
    t.text     "email_body"
  end

  add_index "employment_statuses", ["account_id"], name: "index_employment_statuses_on_account_id", using: :btree
  add_index "employment_statuses", ["grant_id"], name: "index_employment_statuses_on_grant_id", using: :btree

  create_table "funding_sources", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "grant_id"
  end

  add_index "funding_sources", ["account_id"], name: "index_funding_sources_on_account_id", using: :btree

  create_table "google_places_searches", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "city_id"
    t.float    "score"
    t.integer  "opero_company_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "google_places_searches", ["name", "city_id"], name: "index_google_places_searches_on_name_and_city_id", using: :btree
  add_index "google_places_searches", ["opero_company_id"], name: "index_google_places_searches_on_opero_company_id", using: :btree

  create_table "grant_admins", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "grant_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grant_admins", ["account_id"], name: "index_klass_admins_on_account_id", using: :btree
  add_index "grant_admins", ["grant_id"], name: "index_klass_admins_on_grant_id", using: :btree
  add_index "grant_admins", ["user_id"], name: "index_klass_admins_on_user_id", using: :btree

  create_table "grant_trainee_statuses", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "grant_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "grant_trainee_statuses", ["account_id"], name: "index_grant_trainee_statuses_on_account_id", using: :btree
  add_index "grant_trainee_statuses", ["grant_id"], name: "index_grant_trainee_statuses_on_grant_id", using: :btree

  create_table "grants", force: :cascade do |t|
    t.string   "name",          limit: 255, null: false
    t.date     "start_date",                null: false
    t.date     "end_date",                  null: false
    t.integer  "status",                    null: false
    t.integer  "spots"
    t.integer  "amount"
    t.integer  "account_id",                null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.text     "options"
    t.hstore   "specific_data"
  end

  add_index "grants", ["account_id"], name: "index_grants_on_account_id", using: :btree

  create_table "import_fails", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "import_status_id"
    t.text     "row_data"
    t.string   "error_message",    limit: 255
    t.boolean  "can_retry"
    t.boolean  "geocoder_fail"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "row_no"
  end

  add_index "import_fails", ["account_id"], name: "index_import_fails_on_account_id", using: :btree
  add_index "import_fails", ["import_status_id"], name: "index_import_fails_on_import_status_id", using: :btree

  create_table "import_statuses", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.string   "file_name",       limit: 255
    t.string   "type",            limit: 255
    t.integer  "rows_successful"
    t.integer  "rows_failed"
    t.string   "sector_ids",      limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "klass_id"
    t.text     "params"
    t.string   "status",          limit: 255
    t.text     "data"
    t.text     "aws_file_name"
  end

  add_index "import_statuses", ["account_id"], name: "index_import_statuses_on_account_id", using: :btree

  create_table "job_openings", force: :cascade do |t|
    t.integer  "jobs_no"
    t.string   "skills",      limit: 255
    t.integer  "employer_id",             null: false
    t.integer  "account_id",              null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "job_openings", ["account_id", "employer_id"], name: "index_job_openings_on_account_id_and_employer_id", using: :btree

  create_table "job_search_profiles", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "trainee_id"
    t.text     "skills"
    t.string   "location",            limit: 255
    t.integer  "distance"
    t.string   "key",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "opted_out"
    t.string   "opt_out_reason",      limit: 255
    t.string   "company_name",        limit: 255
    t.string   "title",               limit: 255
    t.string   "salary",              limit: 255
    t.string   "zip",                 limit: 255
    t.date     "start_date"
    t.integer  "opt_out_reason_code"
  end

  add_index "job_search_profiles", ["account_id"], name: "index_job_search_profiles_on_account_id", using: :btree
  add_index "job_search_profiles", ["trainee_id"], name: "index_job_search_profiles_on_trainee_id", using: :btree

  create_table "job_searches", force: :cascade do |t|
    t.string   "keywords",       limit: 255
    t.string   "location",       limit: 255
    t.integer  "user_id"
    t.integer  "account_id",                 null: false
    t.integer  "distance"
    t.integer  "recruiters"
    t.integer  "days"
    t.integer  "klass_title_id"
    t.integer  "count"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "in_state"
  end

  add_index "job_searches", ["account_id", "user_id"], name: "index_job_searches_on_account_id_and_user_id", using: :btree
  add_index "job_searches", ["account_id"], name: "index_job_searches_on_account_id", using: :btree

  create_table "job_shared_tos", force: :cascade do |t|
    t.integer  "account_id",   null: false
    t.integer  "job_share_id", null: false
    t.integer  "trainee_id",   null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "job_shared_tos", ["account_id", "job_share_id"], name: "index_job_shared_tos_on_account_id_and_job_share_id", using: :btree
  add_index "job_shared_tos", ["account_id", "trainee_id"], name: "index_job_shared_tos_on_account_id_and_trainee_id", using: :btree

  create_table "job_shares", force: :cascade do |t|
    t.integer  "account_id",                   null: false
    t.string   "title",            limit: 255
    t.string   "company",          limit: 255
    t.string   "date_posted",      limit: 255
    t.text     "excerpt"
    t.string   "location",         limit: 255
    t.string   "source",           limit: 255
    t.text     "details_url"
    t.integer  "details_url_type"
    t.string   "comment",          limit: 255
    t.integer  "from_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "job_shares", ["account_id"], name: "index_job_shares_on_account_id", using: :btree

  create_table "klass_certificates", force: :cascade do |t|
    t.integer  "account_id",              null: false
    t.integer  "klass_id"
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "klass_certificates", ["account_id", "klass_id"], name: "index_klass_certificates_on_account_id_and_klass_id", using: :btree

  create_table "klass_events", force: :cascade do |t|
    t.integer  "account_id",                 null: false
    t.integer  "klass_id"
    t.string   "name",           limit: 255
    t.date     "event_date"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "notes",          limit: 255
    t.string   "start_ampm",     limit: 255
    t.integer  "start_time_hr"
    t.integer  "start_time_min"
    t.string   "end_ampm",       limit: 255
    t.integer  "end_time_hr"
    t.integer  "end_time_min"
    t.string   "uid",            limit: 255
    t.integer  "sequence"
  end

  add_index "klass_events", ["account_id", "klass_id"], name: "index_klass_events_on_account_id_and_klass_id", using: :btree

  create_table "klass_instructors", force: :cascade do |t|
    t.integer  "account_id", null: false
    t.integer  "klass_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "klass_instructors", ["account_id", "klass_id"], name: "index_klass_instructors_on_account_id_and_klass_id", using: :btree
  add_index "klass_instructors", ["account_id", "user_id"], name: "index_klass_instructors_on_account_id_and_user_id", using: :btree

  create_table "klass_interactions", force: :cascade do |t|
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

  create_table "klass_navigators", force: :cascade do |t|
    t.integer  "account_id", null: false
    t.integer  "klass_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "klass_navigators", ["account_id", "klass_id"], name: "index_klass_navigators_on_account_id_and_klass_id", using: :btree
  add_index "klass_navigators", ["account_id", "user_id"], name: "index_klass_navigators_on_account_id_and_user_id", using: :btree

  create_table "klass_schedules", force: :cascade do |t|
    t.integer  "account_id",                                 null: false
    t.integer  "klass_id"
    t.boolean  "scheduled",                  default: false
    t.integer  "dayoftheweek"
    t.integer  "start_time_hr",              default: 0
    t.integer  "start_time_min",             default: 0
    t.string   "start_ampm",     limit: 255, default: "am"
    t.integer  "end_time_hr",                default: 0
    t.integer  "end_time_min",               default: 0
    t.string   "end_ampm",       limit: 255, default: "pm"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "klass_schedules", ["account_id", "klass_id"], name: "index_klass_schedules_on_account_id_and_klass_id", using: :btree

  create_table "klass_titles", force: :cascade do |t|
    t.integer  "account_id",             null: false
    t.integer  "klass_id",               null: false
    t.string   "title",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "klass_titles", ["account_id", "klass_id"], name: "index_klass_titles_on_account_id_and_klass_id", using: :btree

  create_table "klass_trainees", force: :cascade do |t|
    t.integer  "account_id",                         null: false
    t.integer  "klass_id",                           null: false
    t.integer  "trainee_id",                         null: false
    t.integer  "status",                 default: 1
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "notes",      limit: 255
  end

  add_index "klass_trainees", ["account_id", "klass_id"], name: "index_klass_trainees_on_account_id_and_klass_id", using: :btree
  add_index "klass_trainees", ["account_id", "trainee_id"], name: "index_klass_trainees_on_account_id_and_trainee_id", using: :btree

  create_table "klasses", force: :cascade do |t|
    t.integer  "college_id",                 null: false
    t.string   "name",           limit: 255, null: false
    t.string   "description",    limit: 255
    t.integer  "training_hours"
    t.integer  "credits"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "program_id",                 null: false
    t.integer  "account_id",                 null: false
    t.integer  "grant_id",                   null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "klasses", ["account_id", "grant_id", "program_id"], name: "klasses_index", using: :btree

  create_table "opero_companies", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "phone",             limit: 255
    t.string   "source",            limit: 255
    t.string   "line1",             limit: 255
    t.string   "city",              limit: 255
    t.string   "state_code",        limit: 255
    t.integer  "state_id"
    t.integer  "county_id"
    t.string   "zip",               limit: 255
    t.string   "formatted_address", limit: 255
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "website",           limit: 255
  end

  add_index "opero_companies", ["county_id"], name: "index_opero_companies_on_county_id", using: :btree
  add_index "opero_companies", ["state_id"], name: "index_opero_companies_on_state_id", using: :btree

  create_table "polygons", force: :cascade do |t|
    t.integer  "mappable_id",               null: false
    t.string   "mappable_type", limit: 255, null: false
    t.text     "json"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "polygons", ["mappable_id", "mappable_type"], name: "index_polygons_on_mappable_id_and_mappable_type", using: :btree

  create_table "programs", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "description", limit: 255, null: false
    t.integer  "hours"
    t.integer  "sector_id"
    t.integer  "grant_id",                null: false
    t.integer  "account_id",              null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "programs", ["account_id", "grant_id"], name: "index_programs_on_account_id_and_grant_id", using: :btree

  create_table "races", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "sectors", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "shared_job_statuses", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "trainee_id"
    t.integer  "shared_job_id"
    t.integer  "status"
    t.string   "feedback",      limit: 255
    t.string   "key",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shared_job_statuses", ["account_id"], name: "index_shared_job_statuses_on_account_id", using: :btree
  add_index "shared_job_statuses", ["shared_job_id"], name: "index_shared_job_statuses_on_shared_job_id", using: :btree
  add_index "shared_job_statuses", ["trainee_id"], name: "index_shared_job_statuses_on_trainee_id", using: :btree

  create_table "shared_jobs", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.text     "details_url"
    t.text     "excerpt"
    t.integer  "job_share_id"
    t.integer  "account_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.datetime "date_posted"
  end

  add_index "shared_jobs", ["account_id"], name: "index_shared_jobs_on_account_id", using: :btree
  add_index "shared_jobs", ["job_share_id"], name: "index_shared_jobs_on_job_share_id", using: :btree

  create_table "special_services", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "grant_id"
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "special_services", ["account_id"], name: "index_special_services_on_account_id", using: :btree
  add_index "special_services", ["grant_id"], name: "index_special_services_on_grant_id", using: :btree

  create_table "states", force: :cascade do |t|
    t.string   "code",       limit: 255, null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "states", ["code"], name: "index_states_on_code", unique: true, using: :btree

  create_table "tact_threes", force: :cascade do |t|
    t.integer  "account_id",                  null: false
    t.integer  "trainee_id",                  null: false
    t.integer  "education_level"
    t.string   "recent_employer", limit: 255
    t.string   "job_title",       limit: 255
    t.integer  "years"
    t.text     "certifications"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "tact_threes", ["account_id", "trainee_id"], name: "index_tact_threes_on_account_id_and_trainee_id", using: :btree

  create_table "trainee_assessments", force: :cascade do |t|
    t.integer  "account_id",                null: false
    t.integer  "trainee_id",                null: false
    t.integer  "assessment_id",             null: false
    t.string   "score",         limit: 255
    t.boolean  "pass"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "trainee_assessments", ["account_id", "trainee_id"], name: "index_trainee_assessments_on_account_id_and_trainee_id", using: :btree

  create_table "trainee_emails", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.integer  "klass_id"
    t.text     "trainee_names"
    t.text     "trainee_ids"
    t.string   "subject",       limit: 255
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trainee_emails", ["account_id"], name: "index_trainee_emails_on_account_id", using: :btree
  add_index "trainee_emails", ["klass_id"], name: "index_trainee_emails_on_klass_id", using: :btree
  add_index "trainee_emails", ["user_id"], name: "index_trainee_emails_on_user_id", using: :btree

  create_table "trainee_files", force: :cascade do |t|
    t.integer  "account_id",              null: false
    t.integer  "trainee_id",              null: false
    t.string   "file",        limit: 255
    t.string   "notes",       limit: 255
    t.integer  "uploaded_by"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "trainee_files", ["account_id", "trainee_id"], name: "index_trainee_files_on_account_id_and_trainee_id", using: :btree

  create_table "trainee_interactions", force: :cascade do |t|
    t.integer  "account_id",                 null: false
    t.integer  "grant_id",                   null: false
    t.integer  "employer_id",                null: false
    t.integer  "trainee_id",                 null: false
    t.integer  "status"
    t.date     "interview_date"
    t.string   "interviewer",    limit: 255
    t.string   "hire_title",     limit: 255
    t.string   "hire_salary",    limit: 255
    t.date     "offer_date"
    t.date     "start_date"
    t.string   "offer_title",    limit: 255
    t.string   "offer_salary",   limit: 255
    t.text     "comment"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "company",        limit: 255
  end

  add_index "trainee_interactions", ["account_id", "grant_id", "employer_id"], name: "trainee_interactions_employer_id_index", using: :btree
  add_index "trainee_interactions", ["account_id", "grant_id", "trainee_id"], name: "trainee_interactions_trainee_id_index", using: :btree

  create_table "trainee_notes", force: :cascade do |t|
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "trainee_id"
  end

  add_index "trainee_notes", ["trainee_id"], name: "index_trainee_notes_on_trainee_id", using: :btree

  create_table "trainee_placements", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "trainee_id"
    t.hstore   "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trainee_placements", ["account_id"], name: "index_trainee_placements_on_account_id", using: :btree
  add_index "trainee_placements", ["info"], name: "index_trainee_placements_on_info", using: :gin
  add_index "trainee_placements", ["trainee_id"], name: "index_trainee_placements_on_trainee_id", using: :btree

  create_table "trainee_races", force: :cascade do |t|
    t.integer  "account_id", null: false
    t.integer  "trainee_id", null: false
    t.integer  "race_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "trainee_races", ["account_id"], name: "index_trainee_races_on_account_id", using: :btree

  create_table "trainee_statuses", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "grant_id"
    t.integer  "grant_trainee_status_id"
    t.integer  "trainee_id"
    t.string   "notes"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "trainee_statuses", ["account_id"], name: "index_trainee_statuses_on_account_id", using: :btree
  add_index "trainee_statuses", ["grant_id"], name: "index_trainee_statuses_on_grant_id", using: :btree
  add_index "trainee_statuses", ["grant_trainee_status_id"], name: "index_trainee_statuses_on_grant_trainee_status_id", using: :btree
  add_index "trainee_statuses", ["trainee_id"], name: "index_trainee_statuses_on_trainee_id", using: :btree

  create_table "trainee_submits", force: :cascade do |t|
    t.integer  "account_id",              null: false
    t.integer  "trainee_id",              null: false
    t.integer  "employer_id",             null: false
    t.string   "title",       limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.date     "applied_on"
    t.integer  "email_id"
  end

  add_index "trainee_submits", ["account_id", "employer_id"], name: "index_trainee_submits_on_account_id_and_employer_id", using: :btree
  add_index "trainee_submits", ["account_id", "trainee_id"], name: "index_trainee_submits_on_account_id_and_trainee_id", using: :btree
  add_index "trainee_submits", ["email_id"], name: "index_trainee_submits_on_email_id", using: :btree

  create_table "trainees", force: :cascade do |t|
    t.string   "first",                  limit: 255
    t.string   "middle",                 limit: 255
    t.string   "last",                   limit: 255
    t.integer  "status"
    t.string   "trainee_id",             limit: 255
    t.date     "dob"
    t.string   "gender",                 limit: 255
    t.string   "disability",             limit: 255
    t.boolean  "veteran"
    t.string   "education",              limit: 255
    t.string   "land_no",                limit: 255
    t.string   "mobile_no",              limit: 255
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "skills_experience",      limit: 255
    t.integer  "account_id",                                      null: false
    t.integer  "grant_id",                                        null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "legal_status"
    t.integer  "funding_source_id"
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "encrypted_trainee_id",   limit: 255
    t.string   "login_id",               limit: 255
    t.integer  "race_id"
    t.integer  "gts_id"
  end

  add_index "trainees", ["account_id", "grant_id"], name: "index_trainees_on_account_id_and_grant_id", using: :btree
  add_index "trainees", ["login_id"], name: "index_trainees_on_login_id", unique: true, using: :btree

  create_table "unemployment_proofs", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "grant_id"
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unemployment_proofs", ["account_id"], name: "index_unemployment_proofs_on_account_id", using: :btree
  add_index "unemployment_proofs", ["grant_id"], name: "index_unemployment_proofs_on_grant_id", using: :btree

  create_table "user_counties", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.integer  "county_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_counties", ["account_id"], name: "index_user_counties_on_account_id", using: :btree
  add_index "user_counties", ["county_id"], name: "index_user_counties_on_county_id", using: :btree
  add_index "user_counties", ["user_id"], name: "index_user_counties_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "first",                  limit: 255,              null: false
    t.string   "last",                   limit: 255,              null: false
    t.string   "location",               limit: 255,              null: false
    t.integer  "role",                                            null: false
    t.integer  "status",                                          null: false
    t.string   "land_no",                limit: 255
    t.string   "ext",                    limit: 255
    t.string   "mobile_no",              limit: 255
    t.string   "comments",               limit: 255
    t.integer  "account_id"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.datetime "last_activity_at"
    t.text     "options"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "employer_files", "accounts"
  add_foreign_key "employer_files", "employers"
  add_foreign_key "employer_files", "users"
  add_foreign_key "grant_trainee_statuses", "accounts"
  add_foreign_key "grant_trainee_statuses", "grants"
  add_foreign_key "trainee_statuses", "accounts"
  add_foreign_key "trainee_statuses", "grant_trainee_statuses"
  add_foreign_key "trainee_statuses", "grants"
  add_foreign_key "trainee_statuses", "trainees"
end
