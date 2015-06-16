class HotJobsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @q = HotJob.ransack(params[:q])
    jobs = @q.result.includes(:employer, :user)
    jobs = jobs.order(params[:q][:s]) if params[:q] && params[:q][:s]
    @hot_jobs = jobs.to_a.paginate(page: params[:page], per_page: 20)
  end

  def show
    @hot_job = HotJob.find(params[:id])
    authorize @hot_job
  end

  def new
    @hot_job = HotJob.new(employer_id: params[:employer_id])
    @hot_job.location = Employer.find(params[:employer_id]).location if params[:employer_id]
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

    @hot_job.update_attributes(params[:hot_job])
  end

  def destroy
    @hot_job = HotJob.find(params[:id])
    authorize @hot_job
    @hot_job.destroy
  end

  private

  def hot_job_params
    hj_params = params[:hot_job].clone
    hj_params[:date_posted] = opero_str_to_date hj_params[:date_posted]
    hj_params[:closing_date] = opero_str_to_date hj_params[:closing_date]
    hj_params
  end
end
