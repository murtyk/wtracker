class HotJob < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  scope :open_jobs, -> { where('closing_date > ?', Date.today) }

  attr_accessible :date_posted, :employer_id, :location,
                  :closing_date, :title, :description, :salary

  belongs_to :account
  belongs_to :user
  belongs_to :employer

  validates :date_posted, presence: true
  validates :closing_date, presence: true
  validates :title, presence: true
  validates :location, presence: true

  after_initialize :init

  def init
    self.date_posted ||= Date.today
    self.closing_date ||= Date.today + 30.days
  end

  def to_label
    title.truncate(30)
  end

  def posted_by
    user.name
  end

  def self.ransackable_attributes(auth_object = nil)
    super & %w(title location)
  end
end
