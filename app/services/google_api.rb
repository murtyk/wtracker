# encoding: utf-8
require 'rest_client'
require 'json'
require 'fuzzystringmatch'

# wrapper for google api to find companies
class GoogleApi
  NEARBY_SEARCH_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
  DETAILS_URL       = 'https://maps.googleapis.com/maps/api/place/details/json'
  TEXT_SEARCH_URL   = 'https://maps.googleapis.com/maps/api/place/textsearch/json'

  def self.search_for_companies(name, city_state)
    return nil if city_state.blank? || name.blank?
    options = { query: "#{name} near #{city_state}" }
    json    = search(TEXT_SEARCH_URL, options)
    return nil unless json && json['results']

    city_name, state_code  = city_state.split(',')

    build_google_companies(json['results'], name, city_name, state_code)
  end

  def self.build_google_companies(results, name, city_name, state_code)
    companies  =
    results.map do |result|
      result[:score] = place_matching_score(result, name, city_name, state_code)
      GoogleCompany.new(result)
    end
    companies.sort! { |a, b| b.score <=> a.score }
    companies[0..19]
  end

  def self.find_company(name, city_name, state_code,
                                           latitude, longitude)
    score, json = find_company_with_score(name, city_name, state_code,
                                          latitude, longitude)
    return nil unless json

    addr_comp = json['address_components']

    address_info = GoogleAddress.new.build_address(addr_comp, json['formatted_address'])
    return nil unless address_info

    json.merge!(address_info)

    json[:score] = score
    json[:score] -= 30 unless json[:city]

    GoogleCompany.new(json)
  end

  def self.text_search(options)
    search(TEXT_SEARCH_URL, options)
  end

  def self.near_by_search(options)
    search(NEARBY_SEARCH_URL, options)
  end

  def self.find_company_with_score(name, city_name, state_code,
                                   latitude, longitude)

    match = company_with_match_score(name, city_name, state_code,
                                     latitude, longitude)
    return nil unless match && match[:score] >= 60

    json = details(reference: match[:reference])
    [match[:score], json]
  end

  def self.generate_addresses(type, lat, lng, n = 10)
    # should try nearby search
    options = { location: "#{lat},#{lng}",
                radius:   10_000,
                types:    type}

    json = near_by_search(options)
    return nil unless json['status'] == 'OK'

    addresses = []

    json['results'][0..(n-1)].each do |r|
      ref = details(reference: r['reference'])

      addr_comp = {
        "formatted_address" => ref["formatted_address"],
        "formatted_phone_number" => ref["formatted_phone_number"]
      }.merge(ref["geometry"])

      addresses << addr_comp
    end

    addresses
  end

  def self.company_with_match_score(name, city_name, state_code,
                                   latitude, longitude)
    json = text_search(query: "#{name} near #{city_name},#{state_code}")

    return nil unless json && json['status'] == 'OK'
    matches = get_best_matches(json, name, city_name, state_code)

    return matches[0] if matches[0][:score] >= 70

    # should try nearby search
    options = { location: "#{latitude},#{longitude}",
                radius:   50_000,
                types:    'establishment',
                name:     name }

    json = near_by_search(options)
    return nil unless json['status'] == 'OK'
    get_best_matches(json, name, city_name, state_code)[0]
  end

  def self.get_best_matches(json, name, city_name, state_code)
    matches = []
    count = 0
    json['results'][0..6].each do |result|
      count += 1
      score = place_matching_score(result, name, city_name, state_code)
      match = { score: score, index: count, reference: result['reference'] }
      matches.push match
    end

    matches.sort! { |a, b| b[:score] <=> a[:score] }

    # debugger
    matches
  end

  def self.place_matching_score(result, name, city_name, state_code)
    r_name, r_city, r_state_code = parse_result_for_matching(result)

    jarow = FuzzyStringMatch::JaroWinklerPure.new
    score = 5 + 75 * jarow.getDistance(name.downcase, r_name)
    score += 10 * jarow.getDistance(r_city, city_name.downcase) if r_city
    score += 10 if r_state_code && (state_code.downcase == r_state_code)
    score.round
  end

  def self.parse_result_for_matching(result)
    address = result['formatted_address']
    address &&= address.downcase.split(',')
    name = result['name'].downcase
    return [name, nil, nil] unless address

    city = address[1] && address[1].squish
    state_code = address[2] && address[2].squish.downcase
    [name, city, state_code]
  end

  def self.details(options)
    details = search(DETAILS_URL, options)
    details['result']
  end

  def self.search(url, options)
    options = options.merge(key: ENV['GOOGLE_KEY'], sensor: :false)
    response = RestClient.get(url, params: options)
    JSON.parse response.body
  end
end
