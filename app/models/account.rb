# Account is tenant in our multi-tenant app.
# account_id is default scope for all the models specific to an account
# account_id is based on the subdomain
# rubocop:disable ClassLength
class Account < ApplicationRecord
  TYPES     = { 1 => 'Grant Recipient', 2 => 'College' }.freeze
  STATUSES  = { 1 => 'Active', 2 => 'Not Active', 3 => 'Readonly' }.freeze
  TRACK_TRAINEE_OPTIONS = { 0 => 'Do not track status',
                            1 => 'Track status by email' }.freeze

  serialize :options

  cattr_accessor :current_id, instance_writer: false, instance_reader: false

  attr_accessor :track_trainee, :mark_jobs_applied, :demo

  # mark_jobs_applied:  when trainee resumes (or any doc) emailed to employers,
  # treat them as jobs applied (trainee submits)

  validates :name, presence: true, length: { minimum: 4, maximum: 60 }
  validates :description, presence: true, length: { minimum: 10, maximum: 100 }
  validates :subdomain, presence: true, length: { minimum: 3, maximum: 12 }
  validates :client_type, presence: true
  validates :status, presence: true

  has_many :grants, dependent: :destroy # only one grant for college
  accepts_nested_attributes_for :grants

  has_many :trainees, dependent: :destroy

  has_many :users, dependent: :destroy
  accepts_nested_attributes_for :users

  has_many :colleges, dependent: :destroy
  has_many :employers, dependent: :destroy

  has_many :assessments, dependent: :destroy
  has_many :funding_sources, dependent: :destroy

  has_many :account_states, dependent: :destroy
  accepts_nested_attributes_for :account_states
  has_many :states, through: :account_states

  has_many :import_statuses, dependent: :destroy

  has_many :job_searches, dependent: :destroy
  has_many :employer_sources, dependent: :destroy

  before_save :save_demo_option
  after_save :generate_demo_data

  after_find :initialize_option_accessors

  def initialize_option_accessors
    self.options ||= {}
    @track_trainee     = options[:track_trainee].to_i
    @mark_jobs_applied = options[:mark_jobs_applied] || false
    @demo              = options[:demo] || false
  end

  def update_options(options_hash)
    self.options ||= {}
    kvs = options_hash.symbolize_keys
    kvs[:track_trainee] &&= kvs[:track_trainee].to_i
    kvs[:mark_jobs_applied] &&= (kvs[:mark_jobs_applied] == 'true')
    self.options = self.options.merge(kvs)
    save
    initialize_option_accessors
  end

  def self.track_trainee_status?
    current_account.track_trainee_status?
  end

  def track_trainee_status?
    @track_trainee > 0
  end

  def option_track_trainee
    (self.options && self.options[:track_trainee]) || 0
  end

  def self.mark_jobs_applied?
    current_account.mark_jobs_applied?
  end

  def mark_jobs_applied?
    @mark_jobs_applied || false
  end

  def director
    users.unscoped.where(account_id: id, role: 1).first
  end

  def director_name
    director && director.name
  end

  def admins
    users.where(role: 2)
  end

  def self.subdomain
    current_account.subdomain
  end

  def self.current_account
    Account.find(Account.current_id)
  end

  def self.colleges
    current_account.colleges
  end

  def self.grants
    current_account.grants
  end

  def self.states
    current_account.states
  end

  def grant_recipient?
    client_type == 1
  end

  def college?
    client_type == 2
  end

  def type
    TYPES[client_type]
  end

  def status_text
    STATUSES[status]
  end

  def states_for_selection
    State.all - states
  end

  def state
    states.first
  end

  def state_code
    state ? state.code : -1
  end

  def account_grants
    Grant.unscoped.where(account_id: id).decorate
  end

  def active_grants
    Grant.unscoped.where(account_id: id).where.not(status: 3).decorate
  end

  def account_import_statuses
    ImportStatus.unscoped.where(account_id: id).order('created_at desc')
  end

  # rubocop:disable AbcSize
  # rubocop:disable MethodLength
  def destroy_all_dependends
    Account.current_id = id
    Address.destroy_all
    Applicant.destroy_all
    Attachment.destroy_all
    College.destroy_all
    Contact.destroy_all
    Email.destroy_all
    Employer.destroy_all
    EmployerFile.destroy_all
    EmployerNote.destroy_all
    EmployerSector.destroy_all
    EmployerSource.destroy_all
    GrantAdmin.destroy_all
    HotJob.destroy_all
    ImportFail.destroy_all
    ImportStatus.destroy_all
    JobOpening.destroy_all
    JobSearch.destroy_all
    JobShare.destroy_all
    JobSharedTo.destroy_all
    KlassCertificate.destroy_all
    KlassEvent.destroy_all
    KlassInstructor.destroy_all
    KlassNavigator.destroy_all
    KlassSchedule.destroy_all
    KlassTitle.destroy_all
    KlassTrainee.destroy_all

    User.destroy_all
    UserCounty.destroy_all
    UserEmployerSource.destroy_all

    destroy_grant_objects
  end

  def destroy_grant_objects
    Grant.all.each do |g|
      Grant.current_id = g.id

      ApplicantReapply.destroy_all
      ApplicantSource.destroy_all
      Assessment.destroy_all
      CertificateCategory.destroy_all
      EmploymentStatus.destroy_all
      FundingSource.destroy_all
      GrantJobLeadCount.destroy_all
      Klass.destroy_all
      KlassCategory.destroy_all
      KlassInteraction.destroy_all
      Program.destroy_all
      SharedJob.destroy_all
      SharedJobStatus.destroy_all
      SpecialService.destroy_all
      TactThree.destroy_all
      Trainee.destroy_all
      TraineeAssessment.destroy_all
      TraineeAutoLeadStatus.destroy_all
      TraineeEmail.destroy_all
      TraineeFile.destroy_all
      TraineeInteraction.destroy_all
      TraineePlacement.destroy_all
      TraineeRace.destroy_all
      TraineeService.destroy_all
      UnemploymentProof.destroy_all
    end
  end

  private

  def save_demo_option
    self.options ||= {}
    self.options = self.options.merge(demo: @demo)
  end

  def generate_demo_data
    DemoData.new.delay.generate(id) if @demo
  end
end
