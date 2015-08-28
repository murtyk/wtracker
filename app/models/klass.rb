# A class has many attributes and relationships
# navigators and instructors get assigned to a call
# class also has events and interactions with employers
# and of course many trainees
class Klass < ActiveRecord::Base
  DEFAULT_EVENTS = ['Information Session', 'Prescreening', 'Class Visit',
                    'Site Visit', 'Graduation'].freeze

  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }

  # permitted
  attr_accessible :program_id, :credits, :description,
                  :end_date, :name, :start_date, :training_hours,
                  :college_id, :klass_schedules_attributes
  validates :name, presence: true, length: { minimum: 3, maximum: 80 }
  validates :college_id, presence: true
  validates :program_id, presence: true

  belongs_to :account
  belongs_to :grant
  belongs_to :program
  belongs_to :college
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

  def calendar
    @calendar ||= KlassCalendar.new(self)
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
    trainees.where('length(email) > 3')
  end

  def trainees_for_job_leads
    trainee_ids = klass_trainees.where(status: [1, 2]).pluck(:trainee_id)
    trainees.where('length(email) > 3 and trainees.id in (?)', trainee_ids)
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

  def trainees_for_selection
    Trainee.all - trainees
  end

  def klass_instructors_sorted
    klass_instructors.joins(:user)
      .where(users: { status: 1 })
      .order('users.first, users.last')
  end

  def klass_navigators_sorted
    klass_navigators.joins(:user)
      .where(users: { status: 1 }).order('users.first, users.last')
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
end
