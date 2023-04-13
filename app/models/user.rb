# frozen_string_literal: true

# user can be director, admin, navigator or instructor
class User < ApplicationRecord
  include UserRoleMixins

  STATUSES = { 1 => 'Active', 2 => 'Not Active' }.freeze
  COPY_JOB_LEADS_OPTIONS = { 0 => 'Do not copy', 1 => 'Copy me' }.freeze

  serialize :options

  default_scope { where(account_id: Account.current_id) }
  # default_scope order('first, last')
  scope :navigators, -> { where('role = 3') }
  scope :instructors, -> { where('role = 4') }

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, authentication_keys: [:email]
  devise :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :pref_copy_jobshares

  store_accessor :data, :acts_as_admin, :default_employer_source_id

  delegate :name, to: :account, prefix: true

  validates :first, presence: true, length: { minimum: 2, maximum: 20 }
  validates :last, presence: true, length: { minimum: 2, maximum: 20 }
  validates :location, presence: true, length: { minimum: 2, maximum: 40 }
  validates :status, presence: true
  validates :role, presence: true
  validates :email, presence: true
  # validates :password, presence: true

  def active_for_authentication?
    # remember to call the super
    # then put our own check to determine "active" state using
    # our own "is_active" column
    super && status == 1
  end

  before_save :cb_before_save
  after_create :cb_after_create

  belongs_to :account

  has_many :job_searches, -> { order 'id DESC' }, dependent: :destroy
  has_many :job_shares, -> { order 'created_at DESC' },
           foreign_key: 'from_id', dependent: :destroy

  has_many :klass_navigators, dependent: :destroy
  has_many :navigator_klasses, through: :klass_navigators, source: :klass

  has_many :klass_instructors, dependent: :destroy
  has_many :instructor_klasses, through: :klass_instructors, source: :klass

  has_many :grant_admins, dependent: :destroy
  has_many :grants, through: :grant_admins
  accepts_nested_attributes_for :grants

  has_many :emails, dependent: :destroy # sent emails
  has_many :trainee_emails, dependent: :destroy # sent emails

  has_many :user_counties, dependent: :destroy
  accepts_nested_attributes_for :user_counties

  has_many :counties, through: :user_counties
  accepts_nested_attributes_for :counties

  has_many :applicants, foreign_key: 'navigator_id'

  has_many :user_employer_sources, dependent: :destroy
  has_many :employer_sources, through: :user_employer_sources

  has_many :hot_jobs, dependent: :destroy

  def employer_source_id
    employer_source.try(:id)
  end

  def employer_source
    EmployerSourceService.find_employer_source(self)
  end

  def copy_job_shares?
    return true unless options[:copy_job_shares]

    options[:copy_job_shares].positive? # 0 means do not forward
  end

  def copy_job_shares=(pref)
    val = pref[:pref_copy_jobshares].to_i
    self.options = options.merge(copy_job_shares: val)
    save
  end

  def last_klass_selected
    (options && options[:last_klass_selected]).to_i
  end

  def last_klass_selected=(klass_id)
    self.options = options.merge(last_klass_selected: klass_id)
    save
  end

  def last_sectors_selected
    options && options[:last_sectors_selected]
  end

  def last_sectors_selected=(sector_ids)
    self.options = options.merge(last_sectors_selected: sector_ids)
    save
  end

  def name
    "#{first} #{last}"
  end

  alias user_name name

  def online?
    # debugger
    last_activity_at && last_activity_at > 3.minutes.ago
  end

  def online_users
    User
      .where('last_activity_at > ? and not id = ?', 3.minutes.ago, id)
      .map(&:name)
  end

  def acts_as_admin?
    acts_as_admin.to_i.positive?
  end

  def active_grants
    # debugger
    return Grant.order(:name) if admin_or_director?
    return active_grants_of_navigator if navigator?

    active_grants_of_instructor
  end

  def klasses
    current_grant = Grant.find Grant.current_id
    return Klass.all if admin_access? || grants.include?(current_grant)
    return navigator_klasses if navigator?
    return instructor_klasses if instructor?
  end

  def klasses_for_selection(all_option = false)
    order = 'colleges.name, klasses.start_date, klasses.end_date'

    ks = klasses.includes(:college).order(order).map { |k| [k.to_label, k.id] }
    return [['All', 0]] + ks if ks.any? && all_option

    ks
  end

  def employer_sources_for_selection
    EmployerSourceService.employer_sources_for_selection(self)
  end

  def employers
    EmployerSourceService.employers(self)
  end

  def deletable?
    KlassNavigator.unscoped.where(user_id: id).count.zero? &&
      GrantAdmin.unscoped.where(user_id: id).count.zero? &&
      Applicant.unscoped.where(navigator_id: id).count.zero?
  end

  private

  def active_grants_of_navigator
    klass_ids = klass_navigators.pluck(:klass_id)
    grant_ids = Klass.unscoped.where(id: klass_ids).pluck(:grant_id).uniq
    grant_ids += grant_admins.pluck(:grant_id)
    Grant.where(id: grant_ids).where.not(status: 3).uniq
  end

  def active_grants_of_instructor
    klass_ids = klass_instructors.pluck(:klass_id)
    grant_ids = Klass.unscoped.where(id: klass_ids).pluck(:grant_id).uniq
    Grant.where(id: grant_ids).where.not(status: 3).uniq
  end

  def cb_before_save
    self.land_no = land_no.delete('^0-9') if land_no
    self.mobile_no = mobile_no.delete('^0-9') if mobile_no
    self.options ||= {}
  end

  def cb_after_create
    EmployerSourceFactory.find_or_create_employer_source(self)
  end
end
