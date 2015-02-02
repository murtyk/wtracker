include CacheHelper
# searches for jobs
# filters in state jobs
class JobSearchServices
  attr_reader :jobs, :jobs_count, :pages

  def initialize(job_search, ip)
    @job_search = job_search
    @request_ip = ip
  end

  def perform_search(page)
    # slices_for_selection = []
    clean_up_stale_jobs_in_mongo
    if in_state
      jobs_in_state_store = JobsInStateStore.where(job_search_id: job_search_id).first
      unless jobs_in_state_store
        jobs_in_state_store = JobsInStateStore.new(job_search_id: job_search_id,
                                                   state_code: state_code)
        jobs_in_state_store.save
      end
      if jobs_in_state_store.searched?
        @jobs = jobs_in_state_store.jobs(page)
        @jobs_count = jobs_in_state_store.count
        @pages = jobs_in_state_store.pages_count

        build_new_job_search

        return [@jobs, @jobs_count, @pages, @new_job_search]
      end
    end

    perform_sh_search(page)

    @jobs = nil if in_state # important it should be nil not [].
                            # [] means no jobs found in case of in state

    [@jobs, @jobs_count, @pages, @new_job_search]
  end

  # job_ids are in "478::Bristol-Myers Squibb::Princeton--- NJ::2" format
  # job_search_id::company name::cityname---statec0de::title_url id
  #       0           1            2                      3
  # OR
  # "478::::Skillman--- NJ::Analytical Scientist::http://api.simplyhired.com/...."
  # job_search_id::name::cityname--- state::title::url
  #      1          2           3             4     5
  #
  # if name or location is missing then we will have title and url

  def self.company_and_jobs_from_cache(job_ids)
    job_search_id, company_name, location = job_ids[0].split('::')
    location.gsub!('---', ',')

    if company_name.blank? || location.blank?
      company = Company.new(company_name, location)
      company.found = false
      job_ids.each do |job_id|
        job_parts = job_id.split('::')
        # debugger
        title_and_url = [job_parts[-2], job_parts[-1]]
        company.titles.push(title_and_url)
      end
      return company
    end

    cache_id = cache_id_sorted_by_score(job_search_id)
    companies = read_cache(cache_id)

    companies.each do |c|
      if c.poster_name == company_name && c.poster_location == location
        company = c
        break
      end
    end

     # company will have all the jobs. we just need the selected ones

    title_ids = job_ids.map { |job_id| job_id.split('::')[3].to_i }

    company.discard_titles_except(title_ids)

    company
  end

  def search_and_filter_in_state(page)
    jobs_in_state_store = JobsInStateStore.where(job_search_id: job_search_id).first
    jobs_in_state_store ||= JobsInStateStore.create(@job_search)

    job_board = JobBoard.new(@request_ip)

    args = { keywords: keywords.split,
             zip: zip,
             city: city,
             state: state,
             distance: distance,
             days: days,
             page: page,
             page_size: 100
            }

    job_board.search_jobs(args)
    jobs_in_state_store.save_jobs(job_board.jobs)
  end

  private

  def clean_up_stale_jobs_in_mongo
    JobsInStateStore.where(:created_at.lte => 1.hour.ago).destroy
  end

  def perform_sh_search(page)
    kw = keywords.split

    job_board = JobBoard.new(@request_ip)

    args = { keywords: kw, zip: zip, city: city, state: state,
             distance: distance, days: days, page: page
            }

    # for some reason SH returning lesser count when page = 1
    # fix: look ahead for page = 2 to get count

    @jobs_count = 0

    if page == 1
      args[:page] = 2
      @jobs_count = job_board.search_jobs(args)
      args[:page] = 1
    end

    job_board.search_jobs(args)
    @jobs_count = job_board.accessible_count.to_i unless page == 1 && jobs_count > 0

    unless @job_search.count == jobs_count
      @job_search.count = jobs_count
      @job_search.save
    end

    @jobs = job_board.jobs
    @pages = (@jobs_count + 24) / 25

    build_new_job_search
  end

  def build_new_job_search
    @new_job_search = JobSearch.new(location: location,
                                    keywords: keywords,
                                    days: days,
                                    in_state: in_state,
                                    distance: distance)
  end

  def in_state
    @job_search.in_state
  end

  def job_search_id
    @job_search.id
  end

  def state_code
    @job_search.state
  end

  def keywords
    @job_search.keywords
  end

  def location
    @job_search.location
  end

  def zip
    @job_search.zip
  end

  def city
    @job_search.city
  end

  def state
    @job_search.state
  end

  def distance
    @job_search.distance
  end

  def days
    @job_search.days
  end
end
