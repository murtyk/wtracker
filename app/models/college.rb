# frozen_string_literal: true

# an acount can have multiple colleges and
# classes get conducted in a college
# a college should have a physical address
class College < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  default_scope { order(:name) }

  validates :name, presence: true, length: { minimum: 3, maximum: 50 }

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  delegate :line1, :city, :county, :county_id, :state, :zip,
           to: :address, allow_nil: true

  has_many :klasses
  has_many :open_klasses,
           -> { where('start_date > ?', Date.today) },
           class_name: 'Klass'

  def self.locations_hash
    loc = {}
    Account.colleges.each { |c| loc[c.name] = c.city_state }
    loc
  end

  def location
    "#{city},#{county}"
  end

  def city_state
    "#{city},#{state}"
  end

  def formatted_address
    address ? address.gmaps4rails_address : ''
  end

  def self.selection_list
    pluck(:name, :id)
  end
end
