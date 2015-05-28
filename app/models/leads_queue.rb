class LeadsQueue < ActiveRecord::Base
  enum status: [:inactive, :pending, :wip, :processed]
  attr_accessible :trainee_id, :status,
                  :jsp_id, :skills, :distance, :location,
                  :trainee_ip, :last_lead_at,
                  :email_from, :email_reply_to,
                  :email_to, :email_subject, :email_body

  store_accessor :data,
                 :jsp_id, :skills, :distance, :location,
                 :trainee_ip, :last_lead_at,
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
