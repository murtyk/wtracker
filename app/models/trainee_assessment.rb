# reference data for trainee assessment
class TraineeAssessment < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :trainee
  belongs_to :assessment
  attr_accessible :pass, :score, :assessment_id, :trainee_id

  delegate :grant, to: :assessment

  validates :assessment, presence: true
  def assessment_name
    assessment.name
  end

  def status
    pass ? 'Passed' : 'Failed'
  end
end
