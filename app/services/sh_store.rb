# should act like database of jobs from simply hired
class ShStore
  attr_reader :search_params, :job_board

  # sp is an object the responds to keywords, location, distance, days
  def initialize(sp, ip)
    @search_params = {
      keywords: sp.keywords.split,
      city:     sp.location,
      state:    '',
      distance: sp.distance,
      days:     sp.days || 0
    }

    @job_board = JobBoard.new(ip)
  end

  def get_jobs(page_no, search_type = SimplyHired::ALL_KEYWORDS_SEARCH, no_of_jobs = 100)
    args = search_params.merge(page_no:     page_no,
                               search_type: search_type,
                               page_size:  no_of_jobs)

    job_board.search_jobs(args)
    job_board.jobs
  end
end
