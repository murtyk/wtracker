# to capture applicant browser and location information
class Agent < ActiveRecord::Base
  attr_accessible :info # permitted no controller
  belongs_to :identifiable, polymorphic: true
end
