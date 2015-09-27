# reference data trainee education
class Education < ActiveRecord::Base
  default_scope { order(:position) }
end
