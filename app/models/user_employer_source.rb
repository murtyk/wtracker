# frozen_string_literal: true

# Level 1 Navigators can access employers of any source
# level 2 and 3 can only access employers with assigned sources
class UserEmployerSource < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :employer_source
  belongs_to :user

  delegate :name, to: :employer_source

  def default?
    user.default_employer_source_id.to_i == employer_source_id
  end
end
