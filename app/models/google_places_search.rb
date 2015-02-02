# a job search and anlysis resulted in adding opera company
# this captures the search criteria for the opero company
class GooglePlacesSearch < ActiveRecord::Base
  belongs_to :city
  belongs_to :opero_company
  attr_accessible :name, :score, :city_id
end
