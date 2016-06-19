require 'httparty'
require 'mechanize'

# Struct.new('Jd', :details_url_type, :destination_url, :details)
# wrapper for indeed api
class Indeed
  ANY_KEYWORDS_SEARCH = 1
  ALL_KEYWORDS_SEARCH = 2
  attr_reader :keywords, :zip, :city, :state, :distance, :days, :error,
              :location, :count, :jobs,
              :current_page, :page_size, :url

  INDEED_HOME = 'www.indeed.com'
  INDEED_SITE = 'http://api.indeed.com/ads/apisearch?publisher='

  # &q=java&l=austin%2C+tx&sort=&radius=&st=&jt=
  # &start=&limit=&fromage=&filter=&latlong=1&co=us
  # &chnl=&userip=1.2.3.4&useragent=Mozilla/%2F4.0%28Firefox%29&v=2

  def initialize(ip = nil, browser = 'Mozilla/%2F4.0%28Firefox%29')
    @publisher = ENV['PUBLISHER']
    @ip        = ip || RandomIp.fetch
    @browser   = browser
  end

  def user_ip(ip)
    @ip = ip
  end

  def search_jobs(args)
    validate(args)

    @page_size    = args[:page_size] || 25
    @distance     = args[:distance] || 10
    @distance     = 5 if @distance == 0
    @days         = args[:days] || 0
    @current_page = args[:page] || 1
    @keywords     = args[:keywords].join('+OR+')

    @url = ''
    @jobs = nil
    search
  end

  def init_location
    @location = [city.to_s,state.to_s].join(",")
    @location = zip if location.blank?
    @location.sub! ' ', '+'
  end

  def validate(args)
    @city  = args[:city]
    @state = args[:state]
    @zip = args[:zip]
    fail 'indeed - search jobs - missing keywords' if args[:keywords].blank?

    init_location
    location_present = !zip.blank? || !location.blank?

    fail "Indeed location missing" unless location_present
  end

  def next
    if @current_page * @page_size < @count.to_i
      @current_page += 1
      search
    else
      @jobs = nil
    end
  end

  def accessible_count
    count
  end

  def self.new_store(job_search, ip = nil)
    IndeedStore.new(job_search, ip)
  end

  def self.job_count(keywords, city, state, distance = 10, days = 30)
    kws = keywords.split

    args = { keywords: kws,
             zip: '',
             city: city,
             state: state,
             distance: distance,
             days: days
            }
    indeed = Indeed.new
    indeed.search_jobs(args)
    indeed.count
  end

  # def self.get_details(url)
  #   agent = Mechanize.new
  #   page  = agent.get(url)

  #   details_url_type = 0
  #   details = ''

  #   destination_url  = page.uri.to_s

  #   if destination_url.include? INDEED_HOME
  #     details = parse_details(page)
  #     destination_url  = url if details.blank?
  #   end

  #   OpenStruct.new(details_url_type: details_url_type,
  #                  destination_url: destination_url,
  #                  details: details)
  # end

  private

  def self.parse_details(page)
    doc   = page.parser
    nx  = doc.css('.summary') # Nokogiri::XML::NodeSet
    details = build_details(nx[0])
    encode(details)
  rescue
    ''
  end

  def build_details(node)
    return node.children[4].text unless node.children.count > 5

    node.children[0].text + build_details_list(node.children[1].children)
  end

  def build_details_list(nodes)
    '<ul>' +
      nodes.map { |node| '<li>' + node.text + '</li>' }.join +
      '</ul>'
  end

  def search
    build_url

    begin
      response        = HTTParty.get(@url)
      parsed_response =  symbolize JSON.parse(response.parsed_response)
      parse_header(parsed_response)
      @jobs = parse_jobs(parsed_response[:results])
    rescue StandardError => e
      @error = 'Indeed Error - ' + e.to_s
      @jobs = []
      @count = 0
    end

    @count
  end

  Q_V         = '&v=2'
  Q_FORMAT    = '&format=json'

  def build_url
    @url = INDEED_SITE + @publisher + Q_V + Q_FORMAT + q_query +
           q_start + q_limit + q_fromage + q_user_info
  end

  def q_query
    "&q=#{@keywords}&l=#{location}&radius=#{distance}"
  end

  def q_start
    '&start=' + ((@current_page - 1) * @page_size).to_s
  end

  def q_limit
    '&limit=' + @page_size.to_s
  end

  def q_fromage
    '&fromage=' + @days.to_s
  end

  def q_user_info
    "&userip=#{@ip}&useragent=#{@browser}"
  end

  def parse_header(json)
    @count = json[:totalResults]
  end

  def parse_jobs(jobs_array)
    jobs_array.map { |j| IndeedJob.new(j) }
  end

  def symbolize(obj)
    if obj.is_a? Hash
      return obj.each_with_object({}) { |(k, v), memo| memo[k.to_sym] =  symbolize(v) }
    end
    if obj.is_a? Array
      return obj.each_with_object([]) { |v, memo| memo << symbolize(v) }
    end
    obj
  end

  ENCODING_OPTIONS = {
    invalid:          :replace,  # Replace invalid byte sequences
    undef:            :replace,  # Replace anything not defined in ASCII
    replace:          '',        # Use a blank for those replacements
    universal_newline: true       # Always break lines with \n
  }
  def encode(s)
    s.encode Encoding.find('ASCII'), ENCODING_OPTIONS
  end
end
