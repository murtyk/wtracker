# to capture applicant browser and location information
class Agent < ActiveRecord::Base
  attr_accessible :info
  belongs_to :identifiable, polymorphic: true
end
