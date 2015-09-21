# same person can be in more than 1 grants
# one trainee record for each gran
# trainee can be assigned to any number of classes
# status defines placement status and it is updated by TI

class Trainee < ActiveRecord::Base
  LEGAL_STATUSES = { 1 => 'US Citizen', 2 => 'Resident Alien' }
  STATUSES = { 0 => 'Not Placed', 4 => 'Placed', 5 => 'OJT Enrolled' }
  include Encryption
  include ValidationsMixins
  include InteractionsMixins
  include PgSearch
  pg_search_scope :search_by_name,
                  against: [:first, :last],
                  using: { tsearch: { prefix: true } }

  default_scope { where(account_id: Account.current_id, grant_id: Grant.current_id) }

  devise :database_authenticatable, authentication_keys: [:login_id]
  devise :recoverable, :rememberable, :trackable
  extend DeviseOverrides

  # permitted
  attr_accessible :remember_me, :login_id, :password, :password_confirmation,
                  :disability, :dob, :education, :email, :first, :last,
                  :gender, :land_no, :middle, :mobile_no, :trainee_id,
                  :status, :veteran, :race_id, :klass_ids, :edp_date,
                  :tact_three_attributes, :legal_status, :funding_source_id,
                  :home_address_attributes, :mailing_address_attributes

  attr_encrypted :trainee_id, key: :encryption_key

  validates :first, presence: true, length: { minimum: 2, maximum: 20 }
  validates :last,  presence: true, length: { minimum: 2, maximum: 20 }
  validate :validate_email

  validates_uniqueness_of :email, scope: :grant_id, allow_blank: true
  validates_uniqueness_of :login_id, allow_nil: true

  def active_for_authentication?
    # remember to call the super
    # then put our own check to determine "active" state using
    # our own "is_active" column
    super && applicant
  end

  before_save :cb_before_save

  has_one :home_address, as: :addressable,
                         class_name: 'HomeAddress', dependent: :destroy
  accepts_nested_attributes_for :home_address
  delegate :line1, :city, :county, :county_name, :state, :state_code,
           :zip, :latitude, :longitude, to: :home_address, allow_nil: true

  has_one :mailing_address, as: :addressable,
                            class_name: 'MailingAddress', dependent: :destroy
  accepts_nested_attributes_for :mailing_address

  has_one :tact_three, dependent: :destroy
  accepts_nested_attributes_for :tact_three
  delegate :education_name, :recent_employer, :job_title, :years, :certifications,
           to: :tact_three, allow_nil: true

  alias_attribute(:education, :education_name)

  belongs_to :account
  belongs_to :grant
  belongs_to :funding_source
  belongs_to :race

  delegate :name,  to: :funding_source, prefix: true, allow_nil: true

  has_many :trainee_assessments, dependent: :destroy
  has_many :assessments, through: :trainee_assessments
  has_many :trainee_notes, -> { order('created_at DESC') }, dependent: :destroy

  has_many :trainee_interactions, -> { order('created_at DESC') }, dependent: :destroy
  has_many :interested_employers,
           source: :employer, through: :trainee_interactions

  has_one :hired_interaction, -> { where termination_date: nil },
          class_name: 'TraineeInteraction'

  has_many :klass_trainees, dependent: :destroy
  has_many :klasses, through: :klass_trainees

  has_many :trainee_submits, dependent: :destroy
  has_many :trainee_files, dependent: :destroy

  has_many :job_shared_tos # job_share should do dependent: :destroy
  has_many :job_shares, -> { order('created_at DESC') },
           through: :job_shared_tos

  has_one :job_search_profile, dependent: :destroy
  has_many :auto_shared_jobs, dependent: :destroy
  delegate :skills, to: :job_search_profile, allow_nil: :true

  has_one :applicant, dependent: :destroy
  delegate :applied_on, :last_wages, :last_job_title,
           :sector_name, :navigator_name, :source,
           to: :applicant, allow_nil: true
  has_many :trainee_placements, dependent: :destroy

  has_one :agent, as: :identifiable, dependent: :destroy
  has_one :leads_queue, dependent: :destroy

  after_initialize :init

  def self.reset_password_keys
    [:login_id]
  end

  def init
    self.trainee_id  ||= ''
    if new_record? && !(grant && grant.trainee_applications?)
      self.password              ||= 'password'
      self.password_confirmation ||= 'password'
    end
    self.email ||= ''
  end

  def name
    middle.blank? ? "#{first} #{last}" : "#{first} #{middle} #{last}"
  end

  def funding_source_name
    funding_source ? funding_source.name : 'N/A'
  end

  def formatted_address
    home_address ? home_address.gmaps4rails_address : ''
  end

  def hired_employer_interaction
    trainee_interactions.where(status: [4, 5, 6], termination_date: nil).first
  end

  delegate :start_date, :employer_name, :hire_title, :hire_salary,
           to: :hired_employer_interaction, allow_nil: true

  # placed with No OJT or OJT Completed
  def hired?
    status == 4
  end

  # not hired and not OJT Enrolled
  def not_placed?
    status == 0
  end

  def placement_status
    STATUSES[status]
  end

  def klass_names
    klasses.pluck(:name)
  end

  def trainee?
    true
  end

  def valid_email?
    !email.blank?
  end

  def valid_profile?
    job_search_profile && job_search_profile.valid_profile?
  end

  def opted_out_from_auto_leads?
    job_search_profile && job_search_profile.opted_out
  end

  def not_viewed_job_leads_count
    auto_shared_jobs.where(status: [0, nil]).count
  end

  def viewed_job_leads_count
    auto_shared_jobs.where(status: 1).count
  end

  def applied_job_leads_count
    auto_shared_jobs.where('status = 2').count
  end

  def not_interested_job_leads_count
    auto_shared_jobs.where(status: [3, 4]).count
  end

  def job_lead_counts_by_status
    {
      'Not Viewed'     => not_viewed_job_leads_count,
      'Viewed'         => viewed_job_leads_count,
      'Applied'        => applied_job_leads_count,
      'Not Interested' => not_interested_job_leads_count
    }
  end

  def job_leads_count
    auto_shared_jobs.count
  end

  delegate :opted_out_reason, :opted_out_date, :opted_out_reason_desc,
           :opted_out_new_employer, :opted_out_title, :opted_out_start_date,
           to: :job_search_profile, allow: nil

  def pending_data?
    trainee_id.blank? || dob.blank?
  end

  def pending_files_upload?
    return false if trainee_files.any?

    !(applicant.unemployment_proof_initial &&
      applicant.unemployment_proof_date &&
      applicant.skip_resume)
  end

  def completed_trainee_data?
    !(pending_data? || pending_files_upload?)
  end

  def klasses_for_selection
    ks = Klass.where('start_date > ?', Date.today) - klasses
    ks.map { |k| [k.to_label + '-' + k.start_date.to_s + " (#{k.trainees.count})", k.id] }
  end

  def self.status_collection
    [[4, 'Placed'], [5, 'OJT Enrolled'], [0, 'Not Placed']]
  end

  private

  def cb_before_save
    self.land_no   = land_no.delete('^0-9') if land_no
    self.mobile_no = mobile_no.delete('^0-9') if mobile_no
    self.status ||= 0
  end

  def self.ransackable_attributes(auth_object = nil)
    # whitelist only the title and body attributes for other users
    super & %w(first last email funding_source_id mobile_no veteran status)
  end
end
