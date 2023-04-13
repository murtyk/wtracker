# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ModelHelpers

  self.abstract_class = true
end
