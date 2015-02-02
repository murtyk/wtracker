# represents a job in job search
class ShJob
  include JobMixins
  attr_reader :title, :company, :date_posted, :excerpt, :location,
              :source, :details_url, :details_url_type,
              :city, :state, :zip, :county, :country, :city_state,
              :details, :destination_url
  attr_reader :job_json

  def initialize(json)
    @job_json = json
    if job_json['cn']['__content__']
      encoding_options = {
        invalid:          :replace,  # Replace invalid byte sequences
        undef:            :replace,  # Replace anything not defined in ASCII
        replace:          '',        # Use a blank for those replacements
        universal_newline: true       # Always break lines with \n
                          }
      name = job_json['cn']['__content__'].encode Encoding.find('ASCII'), encoding_options
      @company = name.gsub('&amp;', '&')
    end

    @details_url_type = -1

    loc               = job_json['loc']

    @city             = loc['cty']
    @state            = loc['st']
    @zip              = loc['postal']
    @county           = loc['county']
    @country          = loc['country']
    @city_state       = loc['__content__']
    @location         = loc['__content__']
  end

  def title
    job_json['jt']
  end

  def details_url
    job_json['src']['url']
  end

  def destination_url
    job_json['src']['url']
  end

  def source
    job_json['src']['__content__']
  end

  def type
    job_json['ty']
  end

  def date_posted
    Date.parse job_json['dp']
  end

  def excerpt
    job_json['e']
  end
end
