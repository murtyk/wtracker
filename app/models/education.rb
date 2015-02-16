# reference data trainee education
class Education < ActiveRecord::Base
  default_scope { order(:position) }
  attr_accessible :name, :position
  alias_attribute(:education_name, :name)
end
