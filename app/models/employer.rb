# Employer can be added through add menu, imported or
# through job search.
# typical search is on one or more of
# sector, county and/or source
class Employer < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  # default_scope order('employers.name')
  include InteractionsMixins

  scope :order_by_name, -> { order(:name) }
  # scope :name_search, lambda { |name| where("name ILIKE ? ", name+"%")}

  scope :in_county, lambda { |county, state|
                      joins(:address)
                      .where(addresses: { county: county, state: state })
                    }
  scope :in_counties, lambda { |county_ids|
                        joins(:address)
                        .where(addresses: { county_id: county_ids })
                      }
  scope :in_sector, lambda { |sector_id|
                      joins(:employer_sectors)
                      .where(employer_sectors: { sector_id: sector_id })
                    }
  scope :from_source, ->(source) { where(source: source) }

  scope :sources, -> { select('DISTINCT source as source').reorder('source') }

  attr_accessible :name, :source, :address_attributes,
                  :phone_no, :website, :sector_ids, :trainee_ids
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :source, presence: true, length: { minimum: 3, maximum: 100 }

  before_save :cb_before_save

  belongs_to :account

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  delegate :line1, :city, :county, :county_name, :state, :state_code,
           :zip, :latitude, :longitude, to: :address, allow_nil: true

  has_many :employer_sectors, dependent: :destroy
  accepts_nested_attributes_for :employer_sectors

  has_many :sectors, through: :employer_sectors
  accepts_nested_attributes_for :sectors

  has_many :contacts, as: :contactable, dependent: :destroy

  has_many :klass_interactions, dependent: :destroy
  has_many :klass_events, through: :klass_interactions
  has_many :klasses, -> { uniq }, through: :klass_events

  has_many :trainee_interactions, dependent: :destroy
  has_many :trainees, through: :trainee_interactions
  has_many :job_openings, dependent: :destroy
  has_many :trainee_submits, dependent: :destroy
  has_many :employer_notes, -> { order 'created_at desc' }, dependent: :destroy
  has_many :employer_files, dependent: :destroy

  def formatted_address
    address ? address.gmaps4rails_address : ''
  end

  def location
    address && "#{city}-#{county}"
  end

  def city_state
    "#{city},#{state}"
  end

  def sorted_employer_sectors
    employer_sectors.joins(:sector).order('sectors.name')
  end

  def sectors_for_selection
    Sector.all - sectors
  end

  def trainee?
    false
  end

  def self.existing_employer_id(name, lat, lng)
    emp = existing_employer(name, lat, lng)
    emp && emp.id
  end

  def self.existing_employer(name, lat, lng)
    Employer.joins(:address)
            .where(
              'name ILIKE ? and round(addresses.latitude::numeric, 2)= ?
              and round(addresses.longitude::numeric, 2) = ?',
              name, lat.to_f.round(2), lng.to_f.round(2)
            )
            .first
  end

  def duplicate?(assume_no_address = false)
    return duplicate_with_address if !assume_no_address && address

    existing_employers = Employer.where('name ILIKE ? ', name)

    existing_employers.each do |employer|
      unless employer.address
        return true if new_record?
        return true unless employer.id == id
      end
    end
    false
  end

  def duplicate_with_address
    dupes = Employer.joins(:address)
                    .where(
                      'name ILIKE ? and addresses.line1 ILIKE ?
                      and addresses.city ILIKE ? and state ILIKE ?',
                      name, address.line1, address.city, address.state
                    )

    return dupes.first if new_record?

    dupes.where('not employers.id = ?', id).first
  end

  def self.find_by_name_and_zip(name, zip)
    includes(:address)
    .where('employers.name ilike ? and addresses.zip = ?', name, zip)
    .references(:addresses)
    .first
  end

  private

  def cb_before_save
    self.phone_no = phone_no.delete('^0-9') unless phone_no.blank?
  end
end
