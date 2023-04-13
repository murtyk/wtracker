# frozen_string_literal: true

# states in USA
class State < ApplicationRecord
  default_scope { order(:name) }
  has_many :counties, -> { order(:name) }
  has_many :cities

  def self.check_and_get(s)
    where('code ilike ? or name ilike ?', s.squish, s.squish).first
  end

  def self.valid_state_code?(state_code)
    where('code ilike ?', state_code.squish).first ? true : false
  end

  def get_county(cn)
    county = counties.where('name ilike ?', cn.squish).first
    unless county
      # remove the 'county' from 'mercer county'
      county_name = cn.gsub('County', '')
      county = counties.where('name ilike ?', county_name.squish).first
    end
    county
  end

  def county_names_with_state_prefex
    counties.map { |c| "#{code} - #{c.name}" }
  end

  def self.collection_codes
    pluck(:code).sort
  end
end
