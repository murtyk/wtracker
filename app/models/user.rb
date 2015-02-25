# user can be director, admin, navigator or instructor
class User < ActiveRecord::Base
  include UserRoleMixins

  STATUSES       = { 1 => 'Active', 2 => 'Not Active' }
  COPY_JOB_LEADS_OPTIONS = { 0 => 'Do not copy', 1 => 'Copy me' }

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

  # Setup accessible (or protected) attributes for your model
  attr_accessible :remember_me, :password, :password_confirmation,
                  :options, :email, :location, :status, :role,
                  :first, :last, :land_no, :ext, :mobile_no, :comments,
                  :county_ids, :grant_ids, :acts_as_admin
  # attr_accessible :title, :body
  attr_accessor :pref_copy_jobshares

  store_accessor :data, :acts_as_admin

  delegate :account_name, to: :account

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

  belongs_to :account

  has_many :job_searches, -> { order 'id DESC' }, dependent: :destroy
  has_many :job_shares, -> { order 'created_at DESC' },
           foreign_key: 'from_id',  dependent: :destroy

  has_many :klass_navigators, dependent: :destroy
  has_many :navigator_klasses, through: :klass_navigators, source: :klass

  has_many :klass_instructors, dependent: :destroy
  has_many :instructor_klasses, through: :klass_instructors, source: :klass

  has_many :grant_admins, dependent: :destroy
  has_many :grants, through: :grant_admins
  accepts_nested_attributes_for :grants

  has_many :emails, dependent: :destroy   # sent emails
  has_many :trainee_emails, dependent: :destroy   # sent emails

  has_many :user_counties, dependent: :destroy
  accepts_nested_attributes_for :user_counties

  has_many :counties, through: :user_counties
  accepts_nested_attributes_for :counties

  has_many :applicants, foreign_key: 'navigator_id'

  def copy_job_shares?
    return true unless options[:copy_job_shares]
    options[:copy_job_shares] > 0 # 0 means do not forward
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

  alias_method :user_name, :name

  def online?
    # debugger
    last_activity_at && last_activity_at > 3.minutes.ago
  end

  def online_users
    User.where('last_activity_at > ? and not id = ?', 3.minutes.ago, id).map(&:name)
  end

  def acts_as_admin?
    acts_as_admin.to_i > 0
  end

  def active_grants
    # debugger
    return Grant.where.not(status: 3).order(:name) if admin_or_director?
    return active_grants_of_navigator if navigator?
    active_grants_of_instructor
  end

  def klasses
    return Klass.all if admin_or_director? || grant_admin?
    return navigator_klasses.uniq if navigator?
    return instructor_klasses.uniq if instructor?
  end

  def klasses_for_selection(all_option = false)
    ks = klasses.map { |k| [k.to_label, k.id] }
    return [['All', 0]] + ks if ks.any? && all_option
    ks
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
end
