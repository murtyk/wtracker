# for searching companies
class CompanyFinder
  def self.google_search(filters)
    name = filters[:name]
    location = filters[:location]
    return nil if name.blank? || location.blank?

    city = GeoServices.findcity(location)
    return nil unless city

    GoogleApi.search_for_companies(name, city.city_state)
  end

  def find(company)
    @company    = company
    gps, oc     = find_opero_company
    gc, gps, oc = find_google_places_company unless oc
    if oc
      emp = existing_employer(oc, nil, company.employer_source_id)
      emp ? company.found_employer(emp, gps.score) : company.found_oc(gps, oc)
      return
    end

    if gc
      emp = existing_employer(nil, gc, company.employer_source_id)
      emp ? company.found_employer(emp, gc.score) : company.found_gc(gc)
      return
    end
    company.not_found
  end

  def find_opero_company
    gps = GooglePlacesSearch.where('name ilike ? and city_id = ?',
                                   poster_name, poster_city_id).first
    oc = gps && gps.opero_company
    [gps, oc]
  end

  def find_google_places_company
    p_city = City.find(poster_city_id)
    gc     = GoogleApi.find_company(
      poster_name,
      p_city.name,
      p_city.state_code,
      p_city.latitude,
      p_city.longitude)

    return nil unless gc && gc.longitude && gc.latitude

    if gc.score > 90
      gps, oc   = add_gc_to_opero(gc, poster_name, poster_city_id)
      return [gc, gps, oc]
    end

    [gc]
  end

  def existing_employer(oc, gc = nil, employer_source_id)
    if oc && oc.name
      return Employer.existing_employer(oc.name, employer_source_id, oc.latitude, oc.longitude)
    elsif gc && gc.name
      return Employer.existing_employer(gc.name, employer_source_id, gc.latitude, gc.longitude)
    end

    nil
  end

  def poster_name
    @company.poster_name
  end

  def poster_location
    @company.poster_location
  end

  def poster_city_id
    @company.poster_city_id
  end

  def add_gc_to_opero(gc, search_name, search_city_id)
    # first check if gps and oc already in db
    oc  = OperoCompany.where(name: gc.name,
                             line1: gc.line1,
                             zip: gc.zip).first

    gps = GooglePlacesSearch.where('name ilike ? and city_id = ?',
                                   search_name, search_city_id).first

    oc  ||= OperoCompany.create_from_gc(gc)
    gps ||= oc.google_places_searches.create(name:    search_name,
                                             score:   gc.score,
                                             city_id: search_city_id)

    [gps, oc]
  end
end
