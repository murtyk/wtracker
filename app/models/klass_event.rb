# frozen_string_literal: true

# a class event.
# many employers can participate
class KlassEvent < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  belongs_to :account
  belongs_to :klass
  has_many :klass_interactions, dependent: :destroy
  has_many :employers,
           -> { order 'employers.name' },
           through: :klass_interactions
  accepts_nested_attributes_for :klass_interactions

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

  before_save :cb_before_save

  def for_klass?(k)
    klass == k
  end

  delegate :name, to: :klass, prefix: true

  def employer_names
    employers.pluck(:name)
  end

  def selection_name
    "#{name} - #{event_date}"
  end

  def cancelled?
    klass_interactions.count == 1 && klass_interactions.first.status == 4
  end

  def next_sequence
    sequence += 1
    save
    sequence
  end

  def cb_before_save
    self.uid ||= generate_uid
    self.sequence ||= -1
    self.sequence += 1
  end

  def generate_uid
    last_ke = KlassEvent.unscoped.where('uid ilike ?', "#{uid_prefix}%").last
    suffix = last_ke.uid.split('-')[-1].to_i + 1 if last_ke
    suffix ||= 1

    uid_prefix + suffix.to_s
  end

  def uid_prefix
    return "#{account.subdomain}-" unless event_date

    "#{account.subdomain}#{event_date.strftime('%Y%m%d')}-"
  end
end
