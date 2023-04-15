# frozen_string_literal: true

class HotJobsController < ApplicationController
  before_action :authenticate_user!

  def index
    @hjs = HotJobsAdvancedSearch.new(current_user)

    respond_to do |format|
      format.html { perform_advanced_search }
      format.js { @hjs.delay.send_results(params[:q]) }
      format.xls { send_advanced_search_results_file }
    end
  end

  def show
    @hot_job = HotJob.find(params[:id])
    authorize @hot_job
  end

  def new
    @hot_job = HotJob.new(employer_id: params[:employer_id])
    if params[:employer_id]
      @hot_job.location = Employer.find(params[:employer_id]).location
    end
    authorize @hot_job
  end

  def edit
    @hot_job = HotJob.find(params[:id])
    authorize @hot_job
  end

  def create
    @hot_job = current_user.hot_jobs.new(hot_job_params)
    authorize @hot_job

    @hot_job.save
  end

  def update
    @hot_job = HotJob.find(params[:id])
    authorize @hot_job

    @hot_job.update(params[:hot_job])
  end

  def destroy
    @hot_job = HotJob.find(params[:id])
    authorize @hot_job
    @hot_job.destroy
  end

  private

  def send_advanced_search_results_file
    @hjs.build_document(params[:q])
    send_file @hjs.file_path, type: 'application/vnd.ms-excel',
                              filename: @hjs.file_name,
                              stream: false
  end

  def perform_advanced_search
    @hot_jobs = @hjs.search(params[:q])
    @q = @hjs.q
    @hot_jobs = @hot_jobs.paginate(page: params[:page], per_page: 20)
  end

  def hot_job_params
    hj_params = params.require(:hot_job)
                      .permit(:date_posted, :employer_id, :location,
                              :closing_date, :title, :description, :salary).clone
    hj_params[:date_posted] = opero_str_to_date hj_params[:date_posted]
    hj_params[:closing_date] = opero_str_to_date hj_params[:closing_date]
    hj_params
  end
end
