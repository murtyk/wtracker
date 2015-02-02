# a job posting from indeed.com
class IndeedJob
  include JobMixins
  attr_reader :title, :company, :date_posted, :excerpt, :location,
              :source, :details_url, :details_url_type,
              :city, :state, :zip, :county, :country, :city_state,
              :details, :destination_url
  attr_reader :job_json

  def initialize(json)
    @job_json = json

    if json[:company]
      encoding_options = {
        invalid:          :replace,  # Replace invalid byte sequences
        undef:            :replace,  # Replace anything not defined in ASCII
        replace:          '',        # Use a blank for those replacements
        universal_newline: true       # Always break lines with \n
                          }
      name = json[:company].encode Encoding.find('ASCII'), encoding_options
      @company = name.gsub('&amp;', '&')
    end

    @details_url_type = -1

    @city             = json[:city]
    @state            = json[:state]
    @country          = json[:country]
    @city_state       = json[:location]
    @location         = json[:formattedLocation]

    @indeed_apply      = json[:indeedApply]
  end

  def title
    job_json[:jobtitle]
  end

  def details_url
    job_json[:url]
  end

  def destination_url
    job_json[:url]
  end

  def source
    job_json[:source]
  end

  def type
    job_json['ty']
  end

  def date_posted
    Date.parse job_json[:date]
  end

  def excerpt
    job_json[:snippet]
  end

  def job_key
    job_json[:jobkey]
  end

  def sponsored?
    job_json[:sponsored]
  end

  def indeed_apply?
    job_json[:indeedApply]
  end

  def destination_type
    indeed_apply? ? 0 : 1
  end
end
