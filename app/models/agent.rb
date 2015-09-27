# to capture applicant browser and location information
class Agent < ActiveRecord::Base
  belongs_to :identifiable, polymorphic: true
end
