# An applicant whose status is declined can reapply after some time
#    when they become eligible
class ApplicantReapply < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id, grant_id: Grant.current_id) }
  attr_accessible :key, :email, :used # permitted
  attr_accessor :salt, :email

  belongs_to :account
  belongs_to :grant
  belongs_to :applicant

  after_initialize :default_values

  def default_values
    @salt ||= grant.id.to_s
  end

  def confirmation_message
    grant.reapply_confirmation_message
  end
end
