include CacheHelper
# searches for jobs
# filters in state jobs
class JobSearchServices
  attr_reader :jobs, :jobs_count, :pages, :job_search
  delegate :in_state, :keywords, :location, :zip, :city, :state,
           :distance, :days, to: :job_search

  def initialize(js, ip)
    @job_search = js
    @request_ip = ip
  end

  def perform_search(page)
    clean_up_stale_jobs_in_mongo
    if in_state

      jobs_in_state_store = find_or_create_in_state_store(job_search_id)

      if jobs_in_state_store.searched?
        @jobs = jobs_in_state_store.jobs(page)
        @jobs_count = jobs_in_state_store.count
        @pages = jobs_in_state_store.pages_count

        build_new_job_search

        return [@jobs, @jobs_count, @pages, @new_job_search]
      end
    end

    job_board_search(page)

    @jobs = nil if in_state # important it should be nil not [].
    # [] means no jobs found in case of in state

    [@jobs, @jobs_count, @pages, @new_job_search]
  end

  def find_or_create_in_state_store(job_search_id)
    store = JobsInStateStore.where(job_search_id: job_search_id).first

    unless store
      store = JobsInStateStore.new(job_search_id: job_search_id, state_code: state_code)
      store.save
    end

    store
  end

  # Jobs are analyzed before calling this method
  # job_ids are in "478::Bristol-Myers Squibb::Princeton--- NJ::2" format
  # job_search_id::company name::cityname---statecode::title_url id
  #       0           1            2                      3
  # OR
  # "478::::Skillman--- NJ::Analytical Scientist::http://api.simplyhired.com/...."
  # job_search_id::name::cityname--- state::title::url
  #      1          2           3             4     5
  #
  # if name or location is missing then we will have title and url
  def self.company_and_jobs_from_cache(job_ids)

    job_search_id, company_name, location, _job_no = job_ids[0].split('::')
    location && location.gsub!('---', ',')
    company_name && company_name.gsub!('---', ',')

    if company_name.blank? || location.blank?
      return build_blank_company(company_name, location, job_ids)
    end

    company = find_company_from_cache(job_search_id, company_name, location)
    company = company.clone

    # company will have all the jobs. we just need the selected ones

    title_ids = job_ids.map { |job_id| job_id.split('::')[3].to_i }

    company.discard_titles_except(title_ids)

    company
  end

  def build_blank_company(company_name, location, job_ids)
    company = Company.new(company_name, location)
    company.found = false
    job_ids.each do |job_id|
      job_parts = job_id.split('::')
      title_and_url = [job_parts[-2], job_parts[-1]]
      company.titles.push(title_and_url)
    end
    company
  end

  def self.find_company_from_cache(job_search_id, company_name, location)
    cache_id = cache_id_sorted_by_score(job_search_id)
    companies = read_cache(cache_id)

    company = nil
    companies.each do |c|
      if c.poster_name == company_name && c.poster_location == location
        company = c
        break
      end
    end
    company
  end

  def search_and_filter_in_state(page)
    jobs_in_state_store = JobsInStateStore.where(job_search_id: job_search_id).first
    jobs_in_state_store ||= JobsInStateStore.create(job_search)

    job_board = JobBoard.new(@request_ip)

    job_board.search_jobs(job_search_args.merge(page: page, page_size: 100))
    jobs_in_state_store.save_jobs(job_board.jobs)
  end

  private

  def clean_up_stale_jobs_in_mongo
    JobsInStateStore.where(:created_at.lte => 1.hour.ago).destroy
  end

  def job_board_search(page)
    job_board = JobBoard.new(@request_ip)

    args = job_search_args.merge(page: page)

    # for some reason SH returning lesser count when page = 1
    # fix: look ahead for page = 2 to get count

    @jobs_count = 0
    @jobs_count = job_board.search_jobs(args.merge(page: 2)) if page == 1

    search_and_process(job_board, page)

    build_new_job_search
  end

  def search_and_process(job_board, page)
    job_board.search_jobs(job_search_args.merge(page: page))

    @jobs_count = job_board.accessible_count.to_i unless page == 1 && jobs_count > 0

    update_count

    @jobs  = job_board.jobs
    determine_page_count
  end

  def update_count
    @job_search.count = jobs_count
    @job_search.save
  end

  def determine_page_count
    @pages = (@jobs_count + 24) / 25
  end

  def build_new_job_search
    @new_job_search = JobSearch.new(location: location,
                                    keywords: keywords,
                                    days: days,
                                    in_state: in_state,
                                    distance: distance)
  end

  def job_search_id
    job_search.id
  end

  def state_code
    state
  end

  def keywords_array
    keywords.split
  end

  def job_search_args
    { keywords: keywords_array,
      zip: zip,
      city: city,
      state: state,
      distance: distance,
      days: days
    }
  end
end
