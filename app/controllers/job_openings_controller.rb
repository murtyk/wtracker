# captures job openings at an employer
class JobOpeningsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @employer = Employer.find(params[:employer_id])
    @job_opening = @employer.job_openings.new
    authorize @job_opening
  end

  def create
    @employer = Employer.find(params[:job_opening][:employer_id])
    params[:job_opening].delete(:employer_id)
    @job_opening = @employer.job_openings.new(params[:job_opening])
    authorize @job_opening

    @job_opening.save
  end
end
