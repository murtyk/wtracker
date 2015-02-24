# Account is tenant in our multi-tenant app.
# account_id is default scope for all the models specific to an account
# account_id is based on the subdomain
class Account < ActiveRecord::Base
  TYPES     = { 1 => 'Grant Recipient', 2 => 'College' }
  STATUSES  = { 1 => 'Active', 2 => 'Not Active', 3 => 'Readonly' }
  TRACK_TRAINEE_OPTIONS = { 0 => 'Do not track status', 1 => 'Track status by email' }

  serialize :options

  attr_accessible :options, :description, :name, :status, :client_type,
                  :subdomain, :logo_file, :users_attributes,
                  :grants_attributes, :account_states_attributes, :demo

  cattr_accessor :current_id, instance_writer: false, instance_reader: false

  attr_accessor :track_trainee, :mark_jobs_applied, :demo

  # mark_jobs_applied:  when trainee resumes (or any doc) emailed to employers,
  # treat them as jobs applied (trainee submits)

  alias_attribute :account_name, :name

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

  before_save :save_demo_option
  after_save :generate_demo_data
  before_destroy { |record| destroy_account(record) }

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
    users.where(role: 1).first
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

  def destroy_account(account)
    ActiveRecord::Base.connection.tables.each do |table|
      next if table.match(/\Aschema_migrations\Z/)
      next if table.match(/\Aaccounts\Z/)
      next if table.match(/\Adelayed_jobs\Z/)
      klass = table.singularize.camelize.constantize
      if klass.instance_methods.include?(:account)
        klass.where(account_id: account.id).each(&:destroy)
      end
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
