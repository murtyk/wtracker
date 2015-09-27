# typically gets instantiated in a job search analysis
# might correspond to an existing employer hence employer_id
# or might correspond to an opero company - hence opero_company_id
# or from google search - hence all attributes for saving into employer
# titles - correspond to jobs posted by this company
class Company
  include CacheHelper

  attr_reader :poster_name, :poster_location, :poster_city_id,
              :employer_source_id,
              :poster_city_name, :poster_county_name, :poster_state_code

  attr_reader :titles, :duplicate, :found, :searched, :circles

  attr_reader :google_company, :score, :gps_id, :opero_company_id
  attr_accessor :employer_id

  def initialize(p_name, p_location, user)
    @employer_source_id   = user.default_employer_source_id
    @poster_name          = p_name.to_s.squish
    @poster_location      = p_location
    city = GeoServices.findcity(@poster_location) unless @poster_location.blank?

    city ? init_city_attrs(city) : (@poster_city_id = nil)

    init_defaults
  end

  def init_city_attrs(city)
    @poster_city_id     = city.id
    @poster_city_name   = city.name
    @poster_county_name = city.county_name
    @poster_state_code  = city.state_code
  end

  def init_defaults
    @titles               = []
    @searched             = false
    @found                = false
    @score                = 0
  end

  # search order: employer, opero company and finally google
  # opero company or google: check for existing employer
  # save in cache
  def search
    @searched = true
    if poster_name.blank? || poster_city_id.blank?
      cacheit(found: false)
      return nil
    end

    CompanyFinder.new(self).find
  end

  def cacheit(data)
    write_cache(cache_key, data, 2.hours)
  end

  def refresh_info
    cache = read_cache(cache_key)
    @found = cache.nil? ? false : cache[:found]

    @searched = true

    return unless @found
    @employer_id      = cache[:employer_id]
    @opero_company_id = cache[:opero_company_id]
    @gps_id           = cache[:gps_id]
    @google_company   = cache[:gc]
    @score            = cache[:score]
  end

  def info_for_add
    return nil unless found
    return { opero_company_id: opero_company_id } if opero_company_id
    google_company.info_for_add
  end

  def status
    return -1 if poster_name.blank? || poster_location.blank?
    return  0 unless searched
    return  1 unless found
    employer_id.to_i == 0 ? 2 : 3
    # 3: searched, found and employer_id > 0
  end

  def circles
    @circles ||= [10, 20].map { |r| Circle.new(r, longitude, latitude).marker }
  end

  def marker
    [{ name: name, title: name, lat: latitude, lng: longitude }] if found
  end

  def county
    poster_state_code.to_s  + ' - ' + poster_county_name.to_s
  end

  def add_title(title_and_url)
    titles.push title_and_url
  end

  def add_titles(ts)
    @titles += ts
  end

  def discard_titles_except(title_indices)
    @titles = titles.values_at(*title_indices)
  end

  def job_count
    titles.count
  end

  def city_state
    @city_id ? City.find(@city_id).city_state : ''
  end

  def row_class
    return 'success' if score > 95
    return 'info'    if score > 75
    return 'warning' if score > 65
    'error-row'
  end

  def name_location_param
    "#{poster_name}::#{poster_location}::#{poster_city_id}"
  end

  def key
    "#{poster_name}--#{poster_location}"
  end

  def poster_name_location
    "#{poster_name}(#{poster_location})"
  end

  def poster_name_location_id
    "#{poster_name}::#{poster_location}::#{poster_city_id}"
  end

  def valid_name_location?
    !poster_name.blank? && !poster_location.blank?
  end

  def employer
    employer_id && Employer.find(employer_id)
  end

  def cache_key
    good_key(poster_name.to_s + '::' + poster_city_id.to_s)
  end

  def good_key(key)
    key.gsub(/[*'`&]/,  '*' => '-s-', "'" => '-q-', '`' => '-a-', '&' => '-m-')
  end

  def found_employer(employer, score)
    @found       = true
    @score       = score
    @employer_id = employer.id
    # cache_employer(employer_id)
    cacheit(found: true, score: score, employer_id: employer_id)
  end

  def found_oc(gps, oc)
    @found             = true
    @score             = gps.score
    @gps_id            = gps.id
    @opero_company_id  = oc.id
    # cache_oc_company(gps, oc)
    cacheit(found: true,
            score: gps.score,
            opero_company_id: oc.id,
            gps_id: gps.id)
  end

  def found_gc(gc)
    @found          = true
    @score          = gc.score
    @google_company = gc
    # cache_google_company(gc)
    cacheit(found: true, score: gc.score, gc: gc)
  end

  def not_found
    @found = false
    cacheit(found: false)
  end

  def object
    return @object if @object
    @object   = Employer.find(employer_id) if employer_id
    @object ||= OperoCompany.find(opero_company_id) if opero_company_id
    @object ||= google_company
  end

  def city_name
    object.city
  end

  delegate :name, :line1, :state_code, :zip, :latitude, :longitude,
           :website, :phone_no, to: :object, allow_nil: true
end
