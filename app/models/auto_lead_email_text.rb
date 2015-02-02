# base class for various email texts in case of auto job leads
# grant specific
class AutoLeadEmailText < ActiveRecord::Base
  # default_scope { where(account_id: Account.current_id) }
  attr_accessible :content, :account_id
  belongs_to :grant
end
