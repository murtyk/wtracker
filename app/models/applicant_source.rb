# grant specific setting - user defined
# applicant selects one
class ApplicantSource < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }
  default_scope { order(:created_at) }

  belongs_to :account
  belongs_to :grant
  belongs_to :grant
  belongs_to :account

  before_save :correct_other

  private

  def correct_other
    st = source.delete('^a-zA-Z').downcase
    self.source = 'Other, Please specify' if st == 'otherpleasespecify'
  end
end
