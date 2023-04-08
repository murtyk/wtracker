# reference data for trainee assessment
class TraineeAssessment < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }

  belongs_to :trainee
  belongs_to :assessment

  delegate :grant, to: :assessment
  delegate :name, to: :assessment

  validates :assessment, presence: true
  delegate :name, to: :assessment, prefix: true

  def status
    pass ? 'Passed' : 'Failed'
  end
end
