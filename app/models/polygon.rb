# frozen_string_literal: true

# polygon coordinates of an area
# primarily used for counties
class Polygon < ApplicationRecord
  belongs_to :mappable
end
