class ApplicantReapply < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id, grant_id: Grant.current_id) }
  attr_accessible :key, :email
  attr_accessor   :salt, :email, :message
  belongs_to :applicant
  belongs_to :account
  belongs_to :grant

  after_initialize :default_values
  after_save       :assign_message

  def default_values
    @salt    ||= grant.id.to_s
    @message ||= grant.reapply_instructions
  end

  def assign_message
    @message ||= grant.reapply_confirmation_message
  end

end
