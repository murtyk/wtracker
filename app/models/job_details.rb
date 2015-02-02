# for redirecting to job posting page
class JobDetails
  attr_reader :title, :location, :company,
              :details_url_type, :details, :destination_url
  def initialize(job_info)
    url = job_info.split(';')[-1]
    jd  = JobBoard.get_details(url)

    @details_url_type = jd.details_url_type
    @destination_url  = jd.destination_url
    @details          = jd.details
  end
end
