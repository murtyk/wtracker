# reference data trainee education
class Education < ActiveRecord::Base
  default_scope { order(:position) }
  attr_accessible :name, :position # permitted
end
