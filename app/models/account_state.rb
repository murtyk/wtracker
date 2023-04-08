# frozen_string_literal: true

# An accoount can have 0, 1 or more states
# typically used for dispaying counties in employer map
class AccountState < ApplicationRecord
  belongs_to :account
  belongs_to :state
  delegate :name, to: :state
end
