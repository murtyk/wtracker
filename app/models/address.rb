# encoding: utf-8
# provides addressable interface.
# Trainee, College and Employers can have addresses
# geocodes address
class Address < ActiveRecord::Base
  include ValidationsMixins

  default_scope { where(account_id: Account.current_id) }
  scope :in_county, ->(county) { where(county: county) }

  alias_attribute(:street_address, :line1)
  alias_attribute(:postal_code, :zip)
  alias_attribute(:state_code, :state)
  alias_attribute(:county_name, :county)

  attr_accessible :city, :county, :county_id, :country, :gmaps,
                  :latitude, :line1, :line2, :longitude, :state, :zip

  # validates :line1, presence: true, length: {minimum: 5, maximum: 40}
  validates :city,  presence: true, length: { minimum: 3, maximum: 30 }
  validates :state, presence: true, length: { minimum: 2, maximum: 2 }
  validate :validate_state_code
  # validates :zip, presence: true, length: {minimum: 5, maximum: 10}

  belongs_to :addressable, polymorphic: true

  # acts_as_gmappable check_process: false # very careful. revisit?
  acts_as_gmappable process_geocoding: false

  def gmaps4rails_address
    "#{line1}, #{city}, #{state}, #{zip}"
  end

  geocoded_by :gmaps4rails_address

  before_save :cb_before_save

  after_validation(on: :update) do
    if self.changed?
      self.longitude = nil
      self.latitude = nil
    end
  end

  def to_s_for_view
    ['' + line1,
     city,
     "#{state} #{zip}",
     'county: <b>' + county_name + '</b>'].join('<br>')
  end

  private

  def cb_before_save
    set_county_before_save
    set_latlong_before_save
    clean_zip
  end

  def set_county_before_save
    return if county && county_id
    xcity = GeoServices.findcity("#{city},#{state}", zip)
    if xcity
      self.county = xcity.county_name
      self.county_id = xcity.county_id
    else
      fail "address error: city not found - #{gmaps4rails_address}"
    end
  end

  def set_latlong_before_save
    return if latitude? && longitude?
    latlong = GeoServices.latlong(gmaps4rails_address)
    if latlong
      self.latitude = latlong[0]
      self.longitude = latlong[1]
    else
      fail "address error: Geocoding failed - #{gmaps4rails_address}"
    end
  end

  def clean_zip
    self.zip = zip[0, 5] if zip.size > 10
  end
end
