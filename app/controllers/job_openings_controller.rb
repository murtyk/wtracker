class JobOpeningsController < ApplicationController
  before_filter :authenticate_user!

  # GET /job_openings/new
  # GET /job_openings/new.json
  def new
    @employer = Employer.find(params[:employer_id])
    @job_opening = @employer.job_openings.new
    authorize @job_opening

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @job_opening }
    end
  end

  # POST /job_openings
  # POST /job_openings.json
  def create
    @employer = Employer.find(params[:job_opening][:employer_id])
    params[:job_opening].delete(:employer_id)
    @job_opening = @employer.job_openings.new(params[:job_opening])
    authorize @job_opening

    @job_opening.save
  end
end
