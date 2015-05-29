# should act like database of jobs from indeed
class IndeedStore
  attr_reader :search_params, :job_board

  # sp is an object the responds to keywords, location, distance, days
  def initialize(sp, request_ip = nil)
    @search_params = {
      keywords: sp.keywords.split,
      city:     city(sp.location),
      state:    state(sp.location),
      distance: sp.distance,
      days:     sp.days || 0
    }

    @job_board = JobBoard.new(request_ip)
  end

  def get_jobs(page_no, search_type = Indeed::ALL_KEYWORDS_SEARCH, no_of_jobs = 100)
    args = search_params.merge(page_no:     page_no,
                               search_type: search_type,
                               page_size:  no_of_jobs)

    # search_jobs(kw, z, c, s, distance = 10, days = 0, page = 1, p = 25)
    job_board.search_jobs(args)
    job_board.jobs
  end

  private

  def city(location)
    location.split(',')[0]
  end

  def state(location)
    location.split(',')[1]
  end
end
