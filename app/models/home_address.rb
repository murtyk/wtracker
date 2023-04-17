# frozen_string_literal: true

class HomeAddress < Address
  def self.ransackable_attributes(auth_object = nil)
    ["account_id", "addressable_id", "addressable_type", "city", "country", "county", "county_id", "county_name", "created_at", "gmaps", "id", "latitude", "line1", "line2", "longitude", "postal_code", "state", "state_code", "street_address", "type", "updated_at", "zip"]
  end
end
