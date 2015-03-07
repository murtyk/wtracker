# A class has many attributes and relationships
# navigators and instructors get assigned to a call
# class also has events and interactions with employers
# and of course many trainees
class Klass < ActiveRecord::Base
  DEFAULT_EVENTS = ['Information Session', 'Prescreening', 'Class Visit',
                    'Site Visit', 'Graduation'].freeze

  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }

  attr_accessible :grant_id, :program_id, :credits, :description,
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

  # [1 => "Enrolled", 2 => "Completed",3 => "Dropped",
  #  4 => "Placed", 5 => "Continuing Education"]
  def trainees_status_counts
    status_counts = {}
    klass_trainees.select('count(*), status')
      .group(:status)
      .each { |kts| status_counts[kts.status] = kts.count.to_i }
    status_counts
  end

  def enrolled_count
    trainees.count # initially enrolled = total
  end

  def dropped_count
    trainees_status_counts[3].to_i
  end

  def completed_count
    # subtract dropped and still in enrolled status ones from total
    enrolled_count - trainees_status_counts[1].to_i - dropped_count
  end

  def continuing_education_count
    trainees_status_counts[5].to_i
  end

  def placed_count
    trainees_status_counts[4].to_i
  end

  def not_placed_count
    trainees_status_counts[2].to_i # still in completed status waiting for placement
  end

  def placement_rate
    # completed and placed together is our target for placement
    dividend   = placed_count + continuing_education_count
    divisor = not_placed_count + placed_count + continuing_education_count
    divisor > 0 ? (dividend.to_f * 100 / divisor).round(0).to_s + '%' : ''
  end

  def klass_trainees_sorted
    klass_trainees.includes(:trainee)
      .order('klass_trainees.status, trainees.first, trainees.last')
      .references(:trainees)
  end

  def klass_trainees_by_status(status)
    klass_trainees_sorted.where(status: status)
  end

  def trainee_count_by_status(status)
    klass_trainees.where(status: status).count
  end

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
    "#{name} - #{college.name}"
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
