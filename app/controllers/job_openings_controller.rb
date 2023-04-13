# frozen_string_literal: true

# captures job openings at an employer
class JobOpeningsController < ApplicationController
  before_action :authenticate_user!

  def new
    @employer = Employer.find(params[:employer_id])
    @job_opening = @employer.job_openings.new
    authorize @job_opening
  end

  def create
    @employer = Employer.find(params[:job_opening][:employer_id])
    @job_opening = @employer.job_openings.new(job_opening_params)
    authorize @job_opening

    @job_opening.save
  end

  private

  def job_opening_params
    params.require(:job_opening).permit(:jobs_no, :skills)
  end
end
