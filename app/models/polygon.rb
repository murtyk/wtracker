# polygon coordinates of an area
# primarily used for counties
class Polygon < ActiveRecord::Base
  belongs_to :mappable
  attr_accessible :json
end
