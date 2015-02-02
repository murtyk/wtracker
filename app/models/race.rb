# ethnicity of a trainee
class Race < ActiveRecord::Base
  default_scope { order(:name) }
  attr_accessible :name
end
