# a navigator might be given admin level access(class creattion) for some grants
class GrantAdmin < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  attr_accessible :account_id
  belongs_to :account
  belongs_to :grant
  belongs_to :user
end
