# frozen_string_literal: true

# for grant with applicants. User has to define through settings menu
class ApplicantSpecialService < ApplicationRecord
  belongs_to :account
  belongs_to :grant
  belongs_to :special_service
  belongs_to :applicant
end
