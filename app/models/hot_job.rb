# frozen_string_literal: true

class HotJob < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  scope :open_jobs, -> { where('closing_date > ?', Date.today) }

  belongs_to :account
  belongs_to :user, optional: true
  belongs_to :employer, optional: true

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
    super & %w[title location]
  end
end
