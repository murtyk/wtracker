# frozen_string_literal: true

# reference data trainee education
class Education < ApplicationRecord
  default_scope { order(:position) }
end
