# frozen_string_literal: true

# added this feature to address the needs of a grant where applicants can apply
# an applicant gets assigned to a navigator based on their county
# navigator - counties will be managed through settings (for a grant) by user
class UserCounty < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }

  belongs_to :user
  belongs_to :county
end
