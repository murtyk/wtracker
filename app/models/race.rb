# ethnicity of a trainee
class Race < ActiveRecord::Base
  default_scope { order(:name) }

  alias_attribute(:race_name, :name)
  alias_attribute(:ethnicity, :name)
end
