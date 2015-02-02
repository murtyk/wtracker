# analyzes jobs found through job search
# analyzes one slice at a time and aggregates them
# at the end, we will a companies collection which gets cached
# each company will have a collections of jobs
class JobsAnalyzer
  attr_reader :job_store, :companies, :county_counts, :includes_google_places,
              :name_locations, :jobs_count, :error, :job_search

  def initialize(js, ip)
    @job_search = js

    if js.in_state
      @job_store = JobsInStateStore.where(job_search_id: job_search_id).first
      @jobs_count = @job_store.count
    else
      @job_store = JobBoard.new_store(js, ip)
      @jobs_count = js.count
    end
  end

  def analyze_slice(page_no)
    cache_id = cache_id_page(page_no)
    unless cache_exist?(cache_id)
      jobs = job_store.get_jobs(page_no)
      companies = analyze_jobs(jobs)
      write_cache(cache_id, companies, 30.minutes)
    end
  end

  def complete_analysis
    return if cache_exist?(cache_id_analyzed) && cache_exist?(cache_id_counties_analyzed)

    merge_companies_from_all_slices

    @county_counts = Hash.new(0)

    companies.each { |company| @county_counts[company.county] += company.job_count }
    @companies.sort! do |a, b|
      v = a.poster_name.blank? ? 1 : nil
      v || (b.poster_name.blank? ? -1 : a.poster_name.downcase <=> b.poster_name.downcase)
    end

    write_cache(cache_id_analyzed, companies, 3.hours)
    write_cache(cache_id_counties_analyzed, county_counts, 3.hours)

    # we dont need slice analysis anymore. delete them all.
    (1..slices).each { |slice| Rails.cache.delete(cache_id_page(slice)) }
  end

  def sort_and_filter(sort_by, county_names)
    @county_counts = read_cache(cache_id_counties_analyzed)
    unless county_counts
      @error = 'county analysis missing'
      return nil
    end

    @companies = read_cache(cache_id_sorted_by_score) || sort_companies_by_score

    unless county_names.blank?
      companies_in_counties = []
      companies.each do |c|
        companies_in_counties.push(c) if county_names.include?(c.county || '')
      end
      @companies = companies_in_counties
    end
    @includes_google_places = true
  end

  def analyze
    @county_counts = read_cache(cache_id_counties_analyzed)
    @companies = read_cache(cache_id_sorted_by_score)

    @error = nil
    return @includes_google_places = true if @companies

    @includes_google_places = false
    @companies = read_cache(cache_id_analyzed)

    unless companies && county_counts
      @error = 'companies or county counts not found in cache'
      return nil
    end

    init_name_locations
    true
  end

  # def jobs_count
  #   @job_search.count
  # end

  def counties_for_selection
    county_collection = county_counts.map { |k, v| [k.to_s + ' ' + v.to_s, k] }
    county_collection.sort! { |a, b| a[0] <=> b[0] }
  end

  def update_company_employer(employer)
    @companies = read_cache(cache_id_sorted_by_score)
    @companies.each do |company|
      if company.name == employer.name &&
         company.latitude == employer.latitude &&
         company.longitude == employer.longitude

        company.employer_id = employer.id
      end
    end
    write_cache(cache_id_sorted_by_score, companies, 2.hours)
  end

  private

  def job_search_id
    job_search.id
  end

  def analyze_jobs(jobs)
    companies = {}
    jobs.each do |job|
      key = "#{job.company}--#{job.location}"
      companies[key] ||= Company.new(job.company, job.location)
      companies[key].add_title [job.title, job.details_url, job.date_posted]
    end
    # return array of unique companies (name+location)
    companies.values
  end

  def merge_companies_from_all_slices
    companies_hash = {}

    (1..slices).each do |slice|
      companies = read_cache(cache_id_page(slice))
      companies.each do |company|
        key = company.key
        if companies_hash.include?(key)
          first_company = companies_hash[key]
          first_company.add_titles company.titles
          companies_hash[key] = first_company
        else
          companies_hash[key] = company
        end
      end
    end
    @companies = companies_hash.values
  end

  def init_name_locations
    @name_locations = read_cache(cache_id_name_locations)
    return if @name_locations
    @name_locations = []

    companies.each do |company|
      @name_locations.push company.poster_name_location_id if company.valid_name_location?
    end

    write_cache(cache_id_name_locations, @name_locations, 2.hours)
  end

  def sort_companies_by_score
    @companies = read_cache(cache_id_analyzed)

    unless companies
      @error = 'companies missing in cache for cache_id_analyzed'
      return nil
    end

    assign_scores

    @companies.sort! do |company1, company2|
      sort_order = company2.score <=> company1.score
      sort_order = (company1.name || '') <=> (company2.name || '')  if sort_order == 0
      sort_order
    end

    # now check for duplicates

    # mark_duplicates

    write_cache(cache_id_sorted_by_score, companies, 2.hours)

    companies
  end

  def assign_scores
    @companies.each { |company| company.refresh_info }
  end

  def mark_duplicates
    info_hash = {}
    @companies.each do |company|
      if company.found && !compnay.employer_id
        key = info[:name] + ':' + info[:latitude].to_s + ':' + info[:longitude].to_s
        info[:duplicate] = info_hash[key]
        company.info = info
        info_hash[key] ||= true
      end
    end
  end

  def slices
    return 0 if jobs_count < 0
    1 + (jobs_count - 1) / JobSearch::JOBS_SLICE_SIZE
  end

  def cache_id_page(page_no)
    "jobs_analyzed_#{job_search_id}_#{page_no}"
  end

  def cache_id_analyzed
    "jobs_analyzed_#{job_search_id}"
  end

  def cache_id_counties_analyzed
    "jobs_county_analysis_#{job_search_id}"
  end

  def cache_id_sorted_by_score
    "jobs_analyzed_sorted_by_score_#{job_search_id}"
  end

  def cache_id_name_locations
    "jobs_search_name_locations_#{job_search_id}"
  end

  def read_cache(key)
    Rails.cache.read(key)
  end

  def write_cache(key, data, expires_in)
    Rails.cache.write(key, data, expires_in: expires_in)
  end

  def cache_exist?(key)
    Rails.cache.exist?(key)
  end
end
