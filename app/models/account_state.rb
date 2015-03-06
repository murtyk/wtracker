# An accoount can have 0, 1 or more states
# typically used for dispaying counties in employer map
class AccountState < ActiveRecord::Base
  belongs_to :account
  belongs_to :state
  attr_accessible :account_id, :state_id
  delegate :name, to: :state
end
