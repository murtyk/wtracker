require 'httparty'
require 'mechanize'

Struct.new('Jd', :details_url_type, :destination_url, :details)
# wrapper for simplyhired api
class SimplyHired
  ANY_KEYWORDS_SEARCH = 1
  ALL_KEYWORDS_SEARCH = 2
  attr_reader :keywords, :zip, :city, :state, :distance, :days, :error,
              :location, :total_count, :accessible_count, :jobs,
              :current_page, :page_size, :url

  SH_HOME = 'www.simplyhired.com'
  SH_SITE = 'http://api.simplyhired.com/a/jobs-api/xml-v2/q-'

  def initialize(ip = nil)
    ip  ||= '174.129.230.199'
    ssty  = '2'
    cflg  = 'r'
    pshid = ENV['PSHID']
    auth  = ENV['SH_AUTH']

    @credentials = "?pshid=#{pshid}&ssty=#{ssty}&cflg=#{cflg}&auth=#{auth}&clip=#{ip}"
  end

  def search_jobs(args)
    @zip          = args[:zip]
    @city         = args[:city]
    @state        = args[:state]
    @page_size    = args[:page_size] || 25
    @distance     = args[:distance] || 10
    @days         = args[:days] || 0
    @current_page = args[:page] || 1

    @keywords = build_keywords(args)
    @location = build_location

    @url = ''
    @jobs = nil
    search @current_page
  end

  def build_keywords(args)
    search_type   = args[:search_type] || ALL_KEYWORDS_SEARCH
    kw            = args[:keywords]
    search_type == ANY_KEYWORDS_SEARCH ? kw.join('+OR+') : kw.join('+')
  end

  def build_location
    loc = zip.to_s.size == 0 ? "#{city},#{state}" : zip
    loc = loc.split(',').map(&:squish).join(',')
    loc.sub(' ', '+')
  end

  def next
    if @current_page * @page_size < @accessible_count.to_i
      @current_page += 1
      search @current_page
    else
      @jobs = nil
    end
  end

  # sp is an object the responds to keywords, location, distance, days
  def self.new_store(sp, ip = nil)
    ShStore.new(sp, ip)
  end

  def self.job_count(keywords, city, state, distance = 10, days = 30)
    kws = keywords.split
    simplyhired = SimplyHired.new('68.36.169.188')

    args = { keywords: kws,
             zip: '',
             city: city,
             state: state,
             distance: distance,
             days: days
            }

    simplyhired.search_jobs(args)
    simplyhired.accessible_count
  end

  def self.get_details(url)
    agent = Mechanize.new
    page  = agent.get(url)

    details_url_type = 0
    details = ''

    destination_url  = page.uri.to_s

    if destination_url.include? SH_HOME
      # find details and destination get_destination_url
      begin
        doc   = page.parser
        link  = doc.css('.apply_button')
        destination_url = link ? "http://#{SH_HOME}" + link.attr('href').value : url
        details = doc.at_css('.job_description').children[0].text
        details_url_type = 1
      rescue # StandardError => e
        details_url_type = 0
        destination_url  = url
        details = ''
      end
    end

    Struct::Jd.new(details_url_type, destination_url, details)
  end

  private

  def search(p = 0)
    @url = build_url(p)
    @url = URI.encode @url
    # debugger
    begin
      response = HTTParty.get(@url)
      parse_header response.parsed_response['shrs']['rq']
      parse_response response.parsed_response['shrs']['rs']['r']
    rescue StandardError => e
      @error = 'SimlyHired Error - ' + e.to_s
      @jobs = []
      @total_count = 0
      @accessible_count = 0
    end

    @accessible_count
  end

  def build_url(p)
    p > 0 ? pn = "/pn-#{p}" : pn = ''
    dist = distance == 0 ? 'exact' : distance

    href = SH_SITE + keywords + '/l-' + location + "/mi-#{dist}"
    href += "/fdb-#{days}" if days > 0

    @url = href + "/ws-#{page_size}" + pn + @credentials
  end

  def parse_header(json)
    @total_count = json['tr'].to_i
    @accessible_count = json['tv'].to_i
  end

  def parse_response(json)
    @jobs = json.map { |j| ShJob.new(j) }
  end
end
