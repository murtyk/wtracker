class AutoSharedJobsController < ApplicationController
  before_filter :authenticate_user!, only: [:index]

  def edit
    if params[:status]
      @auto_shared_job = AutoSharedJob.find(params[:id])
      valid_key = @auto_shared_job.valid_key?(params[:key])
      fail 'invalid key for auto job lead' unless valid_key
      @auto_shared_job.change_status(params[:status].to_i)
      render 'update'
      return
    end
    if current_trainee && params[:for_notes]
      @auto_shared_job = AutoSharedJob.find(params[:id])
      render 'edit_notes'
      return
    end
    fail 'unauthorized access'
  end

  def update
    fail 'unauthorized access' unless current_trainee
    @auto_shared_job = AutoSharedJob.find(params[:id])
    @auto_shared_job.change_notes(params[:auto_shared_job][:notes])
    render 'update_notes'
  end
end
