# ethnicity of a trainee
class Race < ApplicationRecord
  default_scope { order(:name) }

  alias_attribute(:race_name, :name)
  alias_attribute(:ethnicity, :name)
end
