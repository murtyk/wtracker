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
    @ip        = ip || '174.129.230.199'
    @browser   = browser
  end

  def search_jobs(args)
    validate(args)

    @page_size    = args[:page_size] || 25
    @distance     = args[:distance] || 10
    @distance     = 5 if @distance == 0
    @days         = args[:days] || 0
    @current_page = args[:page] || 1
    @keywords     = args[:keywords].join('+OR+')

    @location     = "#{city},#{state}"
    @location.sub! ' ', '+'

    @url = ''
    @jobs = nil
    search
  end

  def validate(args)
    @city  = args[:city]
    @state = args[:state]
    fail 'indeed - search jobs - invalid args' unless city && state && args[:keywords]
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

  def self.job_count(args)
    kws = args[:keywords].split
    args[:keywords] = kws
    indeed = Indeed.new
    indeed.search_jobs(args)
    indeed.count
  end

  def self.get_details(url)
    agent = Mechanize.new
    page  = agent.get(url)

    details_url_type = 0
    details = ''

    destination_url  = page.uri.to_s

    if destination_url.include? INDEED_HOME
      # find details and destination get_destination_url
      begin
        doc   = page.parser
        nx  = doc.css('.summary') # Nokogiri::XML::NodeSet
        details = build_details(nx[0])
        details = encode(details)
      rescue
        destination_url  = url
        details = ''
      end
    end

    OpenStruct.new(details_url_type: details_url_type,
                   destination_url: destination_url,
                   details: details)
  end

  private

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
    "&q=#{@keywords}&l=#{@location}&radius=#{@distance}"
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
      return obj.reduce({}) do |memo, (k, v)|
        memo[k.to_sym] =  symbolize(v)
        memo
      end
    end
    if obj.is_a? Array
      return obj.reduce([]) do |memo, v|
        memo << symbolize(v)
        memo
      end
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
