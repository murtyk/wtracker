# an account can have 1 or more grants
# several programs in a grant
# grant has end date after which it should become read only
class Grant < ActiveRecord::Base
  STATUSES = { 1 => 'Planning', 2 => 'Started', 3 => 'Closed' }
  default_scope { where(account_id: Account.current_id) }

  store_accessor :specific_data, :hidden_sidebars

  include Sidebars

  serialize :options
  attr_accessible :account_id, :end_date, :name, :start_date, :status, :spots, :amount,
                  :auto_job_leads, :profile_request_content_attributes,
                  :profile_request_subject_attributes, :job_leads_subject_attributes,
                  :job_leads_content_attributes, :optout_message_one_attributes,
                  :optout_message_two_attributes, :optout_message_three_attributes,
                  :trainee_applications, :applicant_logo_file,
                  :assessments_include_score, :assessments_include_pass

  attr_accessible :reply_to_email, :reapply_subject, :reapply_body,
                  :reapply_instructions, :reapply_email_not_found_message,
                  :reapply_already_accepted_message,
                  :reapply_confirmation_message,
                  :hot_jobs_notification_subject, :hot_jobs_notification_body

  store_accessor :specific_data,
                 :assessments_include_score, :assessments_include_pass,
                 :reply_to_email, :reapply_subject, :reapply_body,
                 :reapply_instructions, :reapply_email_not_found_message,
                 :reapply_already_accepted_message, :reapply_confirmation_message,
                 :default_trainee_status_id,
                 :hot_jobs_notification_subject, :hot_jobs_notification_body

  validates :name, presence: true, length: { minimum: 4, maximum: 40 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, presence: true
  validates :account_id, presence: true

  cattr_accessor :current_id, instance_writer: false, instance_reader: false
  attr_accessor :auto_job_leads, :trainee_applications, :applicant_logo_file

  belongs_to :account
  has_many :programs, dependent: :destroy
  has_many :klasses, through: :programs
  has_many :klass_trainees, through: :klasses

  has_many :trainees, dependent: :destroy

  has_one :profile_request_content, -> { unscope(where: :account_id) },
          dependent: :destroy
  accepts_nested_attributes_for :profile_request_content
  has_one :job_leads_content, -> { unscope(where: :account_id) }, dependent: :destroy
  accepts_nested_attributes_for :job_leads_content
  has_one :profile_request_subject, -> { unscoped }, dependent: :destroy
  accepts_nested_attributes_for :profile_request_subject
  has_one :job_leads_subject, -> { unscope(where: :account_id) }, dependent: :destroy
  accepts_nested_attributes_for :job_leads_subject
  has_one :optout_message_one, -> { unscope(where: :account_id) }, dependent: :destroy
  accepts_nested_attributes_for :optout_message_one
  has_one :optout_message_two, -> { unscope(where: :account_id) }, dependent: :destroy
  accepts_nested_attributes_for :optout_message_two
  has_one :optout_message_three, -> { unscope(where: :account_id) }, dependent: :destroy
  accepts_nested_attributes_for :optout_message_three

  has_many :applicants
  has_many :applicant_reapplies
  has_many :employment_statuses
  has_many :applicant_sources

  before_save :save_options

  after_find :initialize_option_accessors

  delegate :name, to: :account, prefix: true

  def initialize_option_accessors
    self.options ||= {}
    @auto_job_leads       = options[:auto_job_leads] || false
    @trainee_applications = options[:trainee_applications] || false
    @applicant_logo_file  = options[:applicant_logo_file]
  end

  def auto_job_leads?
    auto_job_leads || trainee_applications
  end

  def trainee_applications?
    trainee_applications
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

    valid_email_message?(profile_request_subject) &&
      valid_email_message?(profile_request_content)
  end

  def valid_email_message?(msg)
    msg && msg.content && !msg.content.blank?
  end

  def active?
    status != 3
  end

  OTHER_PLEASE_SPECIFY = 'Other, Please specify'
  def collection_employment_statuses(applicant)
    statuses = (employment_statuses.pluck(:status)  +
                [applicant.current_employment_status]).compact.uniq

    shift_other_to_end(statuses)
  end

  def collection_applicant_sources(applicant)
    sources = (applicant_sources.pluck(:source) + [applicant.source]).compact.uniq

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
    User.where(id: user_ids).order(:first, :last)
  end

  def assessments_include_score?
    assessments_include_score == '1'
  end

  def assessments_include_pass?
    assessments_include_pass == '1'
  end

  def salt
    atoz = ('a'..'z').map { |x| x }
    atoz.shuffle[0..3].join + '0000' + atoz.shuffle[0..3].join + id.to_s
  end

  def capture_optout_reason?
    !trainee_applications
  end

  private

  def save_options
    auto_job_leads_setting
    if @trainee_applications.is_a? String
      @trainee_applications = @trainee_applications.to_i
      @trainee_applications = @trainee_applications > 0
    end
    self.options ||= {}
    self.options = self.options.merge(auto_job_leads: @auto_job_leads)
    self.options = self.options.merge(trainee_applications: @trainee_applications)
    self.options = self.options.merge(applicant_logo_file: @applicant_logo_file)
  end

  def auto_job_leads_setting
    return unless @auto_job_leads.is_a? String
    ajl = @auto_job_leads.to_i
    @auto_job_leads = ajl > 0
  end
end
