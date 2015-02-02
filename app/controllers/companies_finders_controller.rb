class CompaniesFindersController < ApplicationController
  before_filter :authenticate_user!
  def new
  end

  def create
    @companies_finder = CompanyListFinder.new(params, current_user)
    unless @companies_finder.errors?
      Delayed::Job.enqueue CustomJob.new(current_account)
      @companies_finder.delay.process
    end
    # @companies_finder.process unless @companies_finder.errors?
  end

  def status
    status_info = CompanyListFinder.status(params[:process_id])
    respond_to do |format|
      format.json { render json: status_info }
    end
  end

  def show
    @process_id = params[:process_id]
    @status     = CompanyListFinder.status(params[:process_id])
    @companies  = CompanyListFinder.companies_data(params[:process_id])

    unless @status
      render 'invalid_process_id'
      return
    end
  end

  def add_employer
    status = CompanyListFinder.status(params[:process_id])
    result = {}
    if status
      employer, error = CompanyListFinder.add_employer(params, current_user)
      result[:employer_id] = employer.id unless error
    else
      error = 'Data Expired. Please resubmit the file.'
    end
    result[:error] = error
    respond_to do |format|
      format.json { render json: result }
    end
  end
end
