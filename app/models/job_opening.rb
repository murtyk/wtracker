# navigator captures number of job openings at an employer
class JobOpening < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :employer
  attr_accessible :jobs_no, :skills # permitted

  validates :jobs_no,
            presence: true,
            numericality: { greater_than_or_equal_to: 1 }
  validates :skills, presence: true
end
