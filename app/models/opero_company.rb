# for building company database overtime based on user searches
class OperoCompany < ActiveRecord::Base
  belongs_to :state
  belongs_to :county

  alias_attribute(:phone_no, :phone)
  attr_accessible :city, :formatted_address, :line1, :state_code, :zip,
                  :state_id, :county_id,
                  :latitude, :longitude, :name,
                  :phone_no, :phone, :source, :website,
                  :google_places_searches_attributes

  has_many :google_places_searches, dependent: :destroy
  accepts_nested_attributes_for :google_places_searches

  def opero_company_id
    id
  end

  def county_name
    county.name
  end

  def self.create_from_gc(gc)
    oc = new
    attrs = %w(city line1 state_code zip state_id county_id
               latitude longitude name phone_no source website)
    attrs.each { |attr| oc.send("#{attr}=", gc.send(attr)) }
    oc.source = 'GP'
    oc.save
    oc
  end

  def formatted_address
    line1 + '<br>' + city + ',' + state_code + ' ' + zip
  end
end
