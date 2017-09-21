# an account can have 1 or more grants
# several programs in a grant
# grant has end date after which it should become read only
class Grant < ActiveRecord::Base
  STATUSES = { 1 => 'Planning', 2 => 'Started', 3 => 'Closed' }.freeze
  OTHER_PLEASE_SPECIFY = 'Other, Please specify'.freeze

  default_scope { where(account_id: Account.current_id) }

  store_accessor :specific_data, :hidden_sidebars

  include Sidebars

  serialize :options

  store_accessor :specific_data,
                 :type,
                 :assessments_include_score, :assessments_include_pass,
                 :reply_to_email, :reapply_subject, :reapply_body,
                 :reapply_instructions, :reapply_email_not_found_message,
                 :reapply_already_accepted_message,
                 :reapply_confirmation_message,
                 :default_trainee_status_id,
                 :hot_jobs_notification_subject, :hot_jobs_notification_body,
                 :unemployment_proof_text,
                 :email_password_subject, :email_password_body,
                 :scoped_employers, # TDC grant
                 :trainee_employment_statuses, # TDC grant
                 :navigators_can_create_klasses,
                 :credentials_email_subject, # Amazon grant
                 :credentials_email_content, # Amazon grant
                 :skip_trainee_data_capture # true for Amazon

  validates :name, presence: true, length: { minimum: 3, maximum: 40 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, presence: true
  validates :account_id, presence: true

  cattr_accessor :current_id, instance_writer: false, instance_reader: false
  attr_accessor :auto_job_leads, :trainee_applications,
                :applicant_logo_file, :skip_profile_solication,
                :auto_profiles_1_week_before_klass,
                :dashboard

  belongs_to :account
  has_many :programs, dependent: :destroy
  has_many :klasses, through: :programs
  has_many :klass_trainees, through: :klasses

  has_many :trainees, dependent: :destroy
  has_many :not_disabled_trainees,
           -> { where(disabled_date: nil) },
           class_name: 'Trainee'

  has_one :profile_request_content, -> { unscope(where: :account_id) },
          dependent: :destroy
  accepts_nested_attributes_for :profile_request_content
  has_one :job_leads_content,
          -> { unscope(where: :account_id) },
          dependent: :destroy
  accepts_nested_attributes_for :job_leads_content
  has_one :profile_request_subject, -> { unscoped }, dependent: :destroy
  accepts_nested_attributes_for :profile_request_subject
  has_one :job_leads_subject,
          -> { unscope(where: :account_id) },
          dependent: :destroy
  accepts_nested_attributes_for :job_leads_subject
  has_one :optout_message_one,
          -> { unscope(where: :account_id) },
          dependent: :destroy
  accepts_nested_attributes_for :optout_message_one
  has_one :optout_message_two,
          -> { unscope(where: :account_id) },
          dependent: :destroy
  accepts_nested_attributes_for :optout_message_two
  has_one :optout_message_three,
          -> { unscope(where: :account_id) },
          dependent: :destroy
  accepts_nested_attributes_for :optout_message_three

  has_many :applicants
  has_many :applicant_reapplies
  has_many :employment_statuses, dependent: :destroy
  has_many :applicant_sources, dependent: :destroy

  has_many :grant_admins, dependent: :destroy
  has_many :klass_categories, dependent: :destroy
  has_many :certificate_categories, dependent: :destroy

  has_many :grant_job_lead_counts, dependent: :destroy

  before_save :save_options

  after_find :initialize_option_accessors

  delegate :name, to: :account, prefix: true

  def self.current_grant
    current_id && find(current_id)
  end

  def initialize_option_accessors
    self.options ||= {}
    @auto_job_leads       = options[:auto_job_leads] || false
    @trainee_applications = options[:trainee_applications] || false
    @applicant_logo_file  = options[:applicant_logo_file]
    @skip_profile_solication = options[:skip_profile_solication] || false
    @auto_profiles_1_week_before_klass =
      options[:auto_profiles_1_week_before_klass] || false

    @dashboard = options[:dashboard]
  end

  def auto_job_leads?
    auto_job_leads || trainee_applications
  end

  def trainee_applications?
    trainee_applications
  end

  def has_trainee_employment_statuses?
    trainee_employment_statuses && trainee_employment_statuses.any?
  end

  def trainee_employment_statuses_collection
    JSON.parse trainee_employment_statuses
  end

  def applicant_logo
    applicant_logo_file && Amazon.file_url(applicant_logo_file)
  end

  def delete_applicant_logo
    return unless applicant_logo_file

    Amazon.delete_file(applicant_logo_file)
    @applicant_logo_file = nil
    save
  end

  def trainee_count
    Trainee.count(conditions: "grant_id = #{id}")
  end

  def grant_programs
    Program.unscoped.where(grant_id: id)
  end

  def email_messages_defined?
    return false unless valid_email_message?(job_leads_subject) &&
                        valid_email_message?(job_leads_content)
    return true if trainee_applications?

    return true if skip_profile_solication

    valid_email_message?(profile_request_subject) &&
      valid_email_message?(profile_request_content)
  end

  def valid_email_message?(msg)
    msg && msg.content && !msg.content.blank?
  end

  def active?
    status != 3
  end

  def collection_employment_statuses
    employment_statuses.where(pre_selected: [nil, false]).pluck(:status)
  end

  def collection_applicant_sources(applicant)
    sources = (applicant_sources.pluck(:source) + [applicant.source])
              .compact
              .uniq
              .sort

    shift_other_to_end(sources)
  end

  def shift_other_to_end(collection)
    return collection unless collection.include?(OTHER_PLEASE_SPECIFY)
    collection -= [OTHER_PLEASE_SPECIFY]
    collection + [OTHER_PLEASE_SPECIFY]
  end

  # navigators of any class in this grant +
  # navigators that are give admin rights to this grant
  def navigators
    user_ids = User.joins(klass_navigators: :klass)
                   .where(users: { role: 3, status: 1 }).pluck(:id) +
               User.joins(:grant_admins)
               .where(grant_admins: { grant_id: id })
               .where(users: { role: 3, status: 1 }).pluck(:id)
    nav_ids = navs_assigned_to_trainees
    User.where(id: user_ids + nav_ids).order(:first, :last)
  end

  def navs_assigned_to_trainees
    Applicant.pluck(:navigator_id).uniq
  end

  def assessments_include_score?
    assessments_include_score == '1'
  end

  def assessments_include_pass?
    assessments_include_pass == '1'
  end

  def salt
    atoz = ('a'..'z').to_a
    atoz.sample(4).join + '0000' + atoz.sample(4).join + id.to_s
  end

  def capture_optout_reason?
    !trainee_applications
  end

  private

  def save_options
    auto_job_leads_setting
    trainee_applications_setting

    self.options ||= {}

    self.options = self.options.merge(options_hash)
  end

  def auto_job_leads_setting
    return unless @auto_job_leads.is_a? String
    ajl = @auto_job_leads.to_i
    @auto_job_leads = ajl > 0
  end

  def trainee_applications_setting
    return unless @trainee_applications.is_a? String

    @trainee_applications = @trainee_applications.to_i
    @trainee_applications = @trainee_applications > 0
  end

  def options_hash
    {
      auto_job_leads: @auto_job_leads,
      trainee_applications: @trainee_applications,
      applicant_logo_file: @applicant_logo_file,
      auto_profiles_1_week_before_klass: @auto_profiles_1_week_before_klass,
      dashboard: @dashboard
    }
  end
end
