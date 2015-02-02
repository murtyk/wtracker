# user settings for applicant grant
class EmploymentStatus < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }
  default_scope { order(:created_at) }

  attr_accessible :status, :action, :email_subject, :email_body
  belongs_to :grant
  belongs_to :account
  before_save :correct_other

  def form_title
    (new_record? ? 'Enter' : 'Edit') +  ' Employment Status'
  end

  private

  def correct_other
    st = status.delete('^a-zA-Z').downcase
    self.status = 'Other, Please specify' if st == 'otherpleasespecify'
  end
end
