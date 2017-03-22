# A class has many attributes and relationships
# navigators and instructors get assigned to a call
# class also has events and interactions with employers
# and of course many trainees
class Klass < ActiveRecord::Base
  DEFAULT_EVENTS = ['Information Session', 'Prescreening', 'Class Visit',
                    'Site Visit', 'Graduation'].freeze

  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }

  validates :name, presence: true, length: { minimum: 3, maximum: 80 }
  validates :college_id, presence: true
  validates :program_id, presence: true
  validate :date_field_year_greater_then_two_thousend

  belongs_to :account
  belongs_to :grant
  belongs_to :program
  belongs_to :college
  belongs_to :klass_category

  delegate :line1, :city, :county, :state, :zip, to: :college
  delegate :address, to: :college

  has_many :klass_schedules, -> { order 'dayoftheweek' }, dependent: :destroy
  accepts_nested_attributes_for :klass_schedules

  has_many :klass_navigators, dependent: :destroy
  has_many :navigators, -> { order 'first, last' },
           through: :klass_navigators,
           source: :user

  has_many :klass_instructors, dependent: :destroy
  has_many :instructors, -> { order 'first, last' },
           through: :klass_instructors,
           source: :user

  has_many :klass_events, dependent: :destroy
  has_many :klass_interactions, through: :klass_events

  has_many :klass_certificates, dependent: :destroy

  has_many :klass_trainees, dependent: :destroy
  has_many :trainees, -> { order 'first, last' }, through: :klass_trainees

  has_many :klass_titles, -> { order 'title' }, dependent: :destroy

  before_create :create_events

  delegate :grant,    to: :program
  delegate :name,     to: :program, prefix: true
  delegate :name,     to: :college, prefix: true
  delegate :location, to: :college
  delegate :name, :code, to: :klass_category, prefix: true, allow_nil: true

  def date_field_year_greater_then_two_thousend
   if start_date.present?  
     start_date_year = start_date.strftime("%Y").to_i 
     if start_date.present? && start_date_year < 2000
       errors.add(:start_date, "Year must be greater then 2000")
     end
   end  
   if end_date.present?
     end_date_year = end_date.strftime("%Y").to_i
     if end_date.present? && end_date_year < 2000
       errors.add(:end_date, "Year must be greater then 2000")
     end
   end  
  end

  def college_name_location
    "#{college_name} (#{location})"
  end

  def klass_titles_ids_to_refresh_counts
    klass_titles.map { |kt| kt.id unless kt.valid_job_search_count? }.compact
  end

  # def trainee_count_by_status(status)
  #   klass_trainees.where(status: status).count
  # end

  def trainees_with_email
    trainees.not_disabled.where('length(email) > 3')
  end

  def trainees_for_job_leads
    trainee_ids = klass_trainees.where(status: [1, 2]).pluck(:trainee_id)
    trainees_with_email.where(id: trainee_ids)
  end

  def trainees_markers_for_job_leads
    t_ids = trainees_for_job_leads.pluck(:id)
    addresses = HomeAddress.includes(:addressable)
                .where(addressable_type: 'Trainee', addressable_id: t_ids)
    MapService.new(addresses).markers_json
  end

  def to_label
    label = "#{college.name} - #{name}"
    return label unless start_date
    label += " - #{start_date}"
    return label unless end_date
    label + " - #{end_date}"
  end

  def label_for_trainees_advanced_search
    [id.to_s,name,college.name,start_date.to_s,end_date.to_s].join(" - ")
  end

  def trainees_for_selection
    Trainee
      .where(disabled_date: nil)
      .where.not(id: trainees.select(:id))
      .order(:first, :last)
  end

  def klass_instructors_sorted
    klass_instructors.includes(:user)
      .where(users: { status: 1 })
      .order('users.first, users.last')
  end

  def klass_navigators_sorted
    klass_navigators.includes(:user)
      .where(users: { status: 1 })
      .order('users.first, users.last')
  end

  def instructors_for_selection
    User.instructors - instructors
  end

  def navigators_for_selection
    User.navigators - navigators
  end

  def scheduled_days
    klass_schedules.where(scheduled: true)
  end

  private

  def create_events
    dt = Date.current.next_week
    DEFAULT_EVENTS.each do |e|
      klass_events.new(name: e, event_date: dt)
      dt = dt.next_week
    end
  end

  def not_disabled_trainees
    trainees.not_disabled
  end

  # the following are used by program.rb
  def self.pred_ongoing_klasses
    format("DATE(start_date) <= '%s' and DATE(end_date) >= '%s'",
           Date.today.strftime('%Y-%m-%d'), Date.today.strftime('%Y-%m-%d'))
  end

  def self.pred_completed_klasses
    format("DATE(end_date) < '%s'", Date.today.strftime('%Y-%m-%d'))
  end
end
