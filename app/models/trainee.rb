# same person can be in more than 1 grants
# one trainee record for each gran
# trainee can be assigned to any number of classes
# many employers can be interested in a trainee
class Trainee < ActiveRecord::Base
  LEGAL_STATUSES = { 1 => 'US Citizen', 2 => 'Resident Alien' }
  include Encryption
  include ValidationsMixins
  default_scope { where(account_id: Account.current_id, grant_id: Grant.current_id) }
  # default_scope order('first, last')
  include InteractionsMixins

  devise :database_authenticatable, authentication_keys: [:login_id]
  devise :recoverable, :rememberable, :trackable
  extend DeviseOverrides

  attr_accessible :remember_me, :login_id, :password, :password_confirmation,
                  :disability, :dob, :education, :email, :first, :last,
                  :gender, :land_no, :middle, :mobile_no, :trainee_id,
                  :status, :veteran, :race_id, :race_ids, :klass_ids,
                  :tact_three_attributes, :legal_status, :funding_source_id,
                  :home_address_attributes, :mailing_address_attributes

  attr_encrypted :trainee_id, key: :encryption_key

  validates :first, presence: true, length: { minimum: 2, maximum: 20 }
  validates :last,  presence: true, length: { minimum: 2, maximum: 20 }
  validate :validate_email

  validates_uniqueness_of :email, scope: :grant_id
  validates_uniqueness_of :login_id, allow_nil: true


  def active_for_authentication?
    # remember to call the super
    # then put our own check to determine "active" state using
    # our own "is_active" column
    super && applicant
  end

  before_save :cb_before_save

  # has_one :address, as: :addressable, dependent: :destroy
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
  delegate :education, :recent_employer, :job_title, :years, :certifications,
           to: :tact_three, allow_nil: true

  belongs_to :account
  belongs_to :grant
  belongs_to :funding_source

  has_many :trainee_races, dependent: :destroy
  has_many :races, through: :trainee_races
  # accepts_nested_attributes_for :trainee_races

  has_many :trainee_assessments, dependent: :destroy
  has_many :trainee_notes, -> { order('created_at DESC') }, dependent: :destroy

  has_many :trainee_interactions, dependent: :destroy
  has_many :interested_employers,
           source: :employer, through: :trainee_interactions

  has_many :klass_trainees, dependent: :destroy
  has_many :klasses, through: :klass_trainees

  has_many :trainee_submits, dependent: :destroy
  has_many :trainee_files, dependent: :destroy

  has_many :job_shared_tos # job_share should do dependent: :destroy
  has_many :job_shares, -> { order('created_at DESC') },
           through: :job_shared_tos

  has_one :job_search_profile, dependent: :destroy
  has_many :auto_shared_jobs, dependent: :destroy

  has_one :applicant, dependent: :destroy
  has_many :trainee_placements, dependent: :destroy

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
    trainee_interactions.where(status: 4).first
  end

  delegate :start_date, :employer_name, :hire_title, :hire_salary,
           to: :hired_employer_interaction, allow_nil: true

  def unhire
    trainee_interactions.where(status: 4).each { |ei| ei.unhire }
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

  def job_leads_count
    auto_shared_jobs.count
  end

  delegate :opted_out_reason, :opted_out_date, :opted_out_reason_desc,
           :opted_out_new_employer, :opted_out_title, :opted_out_start_date,
           to: :job_search_profile, allow: nil

  def pending_data?
    trainee_id.blank? || dob.blank?
  end

  def completed_trainee_data?
    !(pending_data? || trainee_files.empty?)
  end

  def klasses_for_selection
    ks = Klass.where('start_date > ?', Date.today) - klasses
    ks.map{ |k| [k.to_label + '-' + k.start_date.to_s + " (#{k.trainees.count})", k.id] }
  end

  private

  def cb_before_save
    self.land_no   = land_no.delete('^0-9') if land_no
    self.mobile_no = mobile_no.delete('^0-9') if mobile_no
  end
end
