# a class event.
# many employers can participate
class KlassEvent < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  belongs_to :klass
  has_many :klass_interactions, dependent: :destroy
  has_many :employers,
           -> { order 'employers.name' },
           through: :klass_interactions
  accepts_nested_attributes_for :klass_interactions
  attr_accessible :event_date, :name, :klass_id, :notes,
                  :start_ampm, :start_time_hr, :start_time_min,
                  :end_ampm, :end_time_hr, :end_time_min
  validates :name, presence: true, length: { minimum: 5 }
  validates :start_time_hr,
            numericality: { greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 12 },
            allow_nil: true
  validates :start_time_min,
            numericality: { greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 59 },
            allow_nil: true
  validates :end_time_hr,
            numericality: { greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 12 },
            allow_nil: true
  validates :end_time_min,
            numericality: { greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 59 },
            allow_nil: true

  after_initialize :init

  def init
    self.uid ||= Account.subdomain + event_date.to_s + id.to_s
    self.sequence ||= -1
  end

  def for_klass?(k)
    klass == k
  end

  def klass_name
    klass.name
  end

  def employer_names
    employers.pluck(:name)
  end

  def selection_name
    "#{name} - #{event_date}"
  end

  def cancelled?
    klass_interactions.count == 1 && klass_interactions.first.status == 4
  end

  def interactions_by_status(status)
    klass_interactions.joins(:employer)
                      .where(status: status)
                      .order('employers.name')
  end

  def next_sequence
    sequence += 1
    save
    sequence
  end
end
