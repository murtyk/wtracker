# frozen_string_literal: true

# grant specific
class ApplicantUnemploymentProof < ApplicationRecord
  belongs_to :account
  belongs_to :grant
  belongs_to :unemployment_proof
  belongs_to :applicant
end
