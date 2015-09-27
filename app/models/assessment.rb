# reference list of assessments of a class
class Assessment < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }
  default_scope { order(:name) }

  belongs_to :account
  belongs_to :grant

  has_many :trainee_assessments
  has_many :trainees, through: :trainee_assessments

  validates :name,
            presence: true,
            length: { minimum: 3, maximum: 50 }

  has_many :trainee_assessments, dependent: :destroy
end
