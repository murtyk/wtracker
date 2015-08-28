# reference data for trainee assessment
class TraineeAssessment < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :trainee
  belongs_to :assessment

  # permitted
  attr_accessible :pass, :score, :assessment_id, :trainee_id, :date

  delegate :grant, to: :assessment

  validates :assessment, presence: true
  delegate :name, to: :assessment, prefix: true

  def status
    pass ? 'Passed' : 'Failed'
  end
end
