# taacct 3 attributes for trainee
class TactThree < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  attr_accessible :certifications, :education_level,
                  :job_title, :recent_employer, :years
  belongs_to :trainee

  def education
    education_level? ? Education.find(education_level).name : ''
  end
end
