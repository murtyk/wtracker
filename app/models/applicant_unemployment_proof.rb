# grant specific
class ApplicantUnemploymentProof < ActiveRecord::Base
  belongs_to :account
  belongs_to :grant
  belongs_to :unemployment_proof
  belongs_to :applicant
end
