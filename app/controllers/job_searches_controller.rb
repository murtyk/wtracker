class JobSearchesController < ApplicationController
  before_filter :authenticate_user!

  def valid_state
    valid = State.valid_state_code?(params[:state_code])
    respond_to do |format|
      format.json { render json: valid }
    end
  end

  def search_and_filter_in_state
    @slice = params[:slice].to_i
    @job_search = JobSearch.find(params[:job_search_id])
    job_search_service = JobSearchServices.new(@job_search, request_ip)
    job_search_service.search_and_filter_in_state(@slice)
    respond_to do |format|
      format.json { render json: @slice }
    end
  end

  def analysis_present
    # debugger
    job_search_id = params[:job_search_id]
    cache_id_a = cache_id_analyzed(job_search_id)
    cache_id_c =  cache_id_counties_analyzed(job_search_id)
    present = cache_exist?(cache_id_a) && cache_exist?(cache_id_c)
    respond_to do |format|
      format.json { render json: present }
    end
  end

  def analyze_slice
    @slice = params[:slice].to_i

    @job_search = JobSearch.find(params[:job_search_id].to_i)
    analyzer = @job_search.analyzer(request_ip)
    analyzer.analyze_slice(@slice)
  end

  def complete_analysis
    @job_search = JobSearch.find(params[:job_search_id])

    @analyzer = @job_search.analyzer
    @analyzer.complete_analysis
    @analyzer.analyze

    respond_to do |format|
      format.js
      format.json { render json: 'done' }
    end
  end

  def analyze
    @job_search = JobSearch.find(params[:id])
    authorize @job_search

    @analyzer = @job_search.analyzer
    unless @analyzer.analyze
      flash[:error] = @analyzer.error
      redirect_to @job_search
      return
    end
  end

  def sort_and_filter
    @job_search = JobSearch.find(params[:id])
    sort_by = params[:sort_by] || 'score'

    county_names = params[:county_ids] && params[:county_ids].split(',')

    if params[:in_state]
      state = current_account.states.first
      if state && state.code == @job_search.state
        county_names = state.county_names_with_state_prefex
      end
    end

    @analyzer = @job_search.analyzer

    @analyzer.sort_and_filter(sort_by, county_names)

    if @analyzer.error
      flash[:error] = @analyzer.error
      redirect_to @job_search
      return
    end

    render 'analyze'
  end

  def google_places_cache_check_and_start
    cache_id = cache_id_google_places(params[:job_search_id])
    exists = cache_exist?(cache_id)
    write_cache(cache_id, 1, 3.hours) unless exists
    respond_to do |format|
      format.json { render json: exists }
    end
  end

  def retrycompanysave
    @company = params[:company]
    @sector_ids  = params[:sector_ids]
    @error = nil
    begin
      attrs = Hash[%w(name phone_no website).zip @company]
      attrs['source'] = 'job search'
      attrs['address_attributes'] = %w(line1 city state zip).zip @company
      e = Employer.new(attrs)
      @sector_ids.each do |sid|
        e.employer_sectors.new(sector_id: sid.to_i)
      end
      e.save
    rescue StandardError => error
      @error = error.to_s
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    # @current_job_search = job_search = JobSearch.find(params[:id])
    # authorize job_search
    # # debugger
    # @page = (params[:page] || 1).to_i

    # @job_search_service = JobSearchServices.new(job_search, request_ip)

    # @jobs, @jobs_count, @pages, @job_search = @job_search_service.perform_search(@page)

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.json { render json: @job_search }
    # end

    @job_search = JobSearch.find(params[:id])
    authorize @job_search
    page = (params[:page] || 1).to_i
    @job_search.perform_search(request_ip, page)
  end

  def details
    authorize JobSearch

    @job_details = JobDetails.new params[:job_info]
    # if @job_details.details_url_type == 0
    redirect_to @job_details.destination_url
    # end
  end

  # GET /job_searches/new
  # GET /job_searches/new.json
  def new
    @job_search = current_user.job_searches.build

    authorize @job_search
  end

  # POST /job_searches
  # POST /job_searches.json
  def create
    params[:job_search].delete(:college_id)
    klass_title_id = params[:job_search][:klass_title_id].to_i

    if klass_title_id > 0
      klass_title = KlassTitle.find(klass_title_id)
      @job_search = klass_title.get_job_search(true)
    else
      @job_search = current_user.job_searches.new(params[:job_search])
    end
    authorize @job_search

    respond_to do |format|
      if @job_search.save
        format.html { redirect_to job_search_path(@job_search) }
        format.json { render json: @job_search, status: :created, location: @job_search }
      else
        format.html { render :new }
        format.json { render json: @job_search.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def request_ip
    request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
  end
end
