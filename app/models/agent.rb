# frozen_string_literal: true

# to capture applicant browser and location information
class Agent < ApplicationRecord
  belongs_to :identifiable, polymorphic: true
end
