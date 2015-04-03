# searches jobs and analyzes
# REFACTOR: It has too many custom routes
class JobSearchesController < ApplicationController
  before_filter :authenticate_user!

  # perhaps this should be on States routes
  def valid_state
    valid = State.valid_state_code?(params[:state_code])
    render json: valid
  end

  def search_and_filter_in_state
    @slice = params[:slice].to_i
    @job_search = JobSearch.find(params[:job_search_id])
    job_search_service = JobSearchServices.new(@job_search, request_ip)
    job_search_service.search_and_filter_in_state(@slice)
    render json: @slice
  end

  def analysis_present
    # debugger
    job_search_id = params[:job_search_id]
    cache_id_a = cache_id_analyzed(job_search_id)
    cache_id_c =  cache_id_counties_analyzed(job_search_id)
    present = cache_exist?(cache_id_a) && cache_exist?(cache_id_c)
    render json: present
  end

  def analyze_slice
    @slice = params[:slice].to_i

    @job_search = JobSearch.find(params[:job_search_id].to_i)
    analyzer = @job_search.analyzer(current_user, request_ip)
    analyzer.analyze_slice(@slice)
  end

  def complete_analysis
    @job_search = JobSearch.find(params[:job_search_id])

    @analyzer = @job_search.analyzer(current_user)
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

    @analyzer = @job_search.analyzer(current_user)
    return if @analyzer.analyze
    flash[:error] = @analyzer.error
    redirect_to @job_search
  end

  def sort_and_filter
    @job_search = JobSearch.find(params[:id])
    @analyzer   = @job_search.analyzer(current_user)

    unless @analyzer.sort_and_filter(params[:sort_by], county_names(params))
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

  def show
    @job_search = JobSearch.find(params[:id])
    authorize @job_search
    page = (params[:page] || 1).to_i
    @job_search.perform_search(request_ip, page)
    @processes_count = ENV['PROCESSES_COUNT'] ? ENV['PROCESSES_COUNT'].to_i : 3
  end

  def details
    authorize JobSearch

    @job_details = JobDetails.new params[:job_info]
    # if @job_details.details_url_type == 0
    redirect_to @job_details.destination_url
    # end
  end

  def new
    @job_search = current_user.job_searches.build
    authorize @job_search
  end

  def create
    @job_search = find_or_new_job_search(params)
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

  def county_names(params)
    return params[:county_ids] && params[:county_ids].split(',') unless params[:in_state]
    state = current_account.states.first
    return nil unless state && state.code == @job_search.state
    state.county_names_with_state_prefex
  end

  def find_or_new_job_search(params)
    params[:job_search].delete(:college_id)
    klass_title_id = params[:job_search][:klass_title_id].to_i

    return current_user.job_searches.new(params[:job_search]) unless klass_title_id > 0

    klass_title = KlassTitle.find(klass_title_id)
    klass_title.get_job_search(true)
  end
end
