# a navigator might be given admin level access(class creattion) for some grants
class GrantAdmin < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :grant
  belongs_to :user

  after_create :cb_after_create

  def cb_after_create
    EmployerSourceFactory.find_or_create_employer_source(user, grant)
  end
end
