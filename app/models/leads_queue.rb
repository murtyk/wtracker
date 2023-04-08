#
class LeadsQueue < ApplicationRecord
  enum status: [:inactive, :pending, :wip, :processed]

  scope :pending, -> { where(status: 1) }

  store_accessor :data,
                 :jsp_id, :skills, :distance, :location, :zip,
                 :trainee_ip, :last_date_posted,
                 :email_from, :email_reply_to,
                 :email_to, :email_subject, :email_body

  validates :trainee_id, presence: true

  belongs_to :trainee

  def start
    update(status: :wip)
  end

  def done
    update(status: :processed)
  end
end
