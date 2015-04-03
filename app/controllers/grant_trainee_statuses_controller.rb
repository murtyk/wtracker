class GrantTraineeStatusesController < ApplicationController
  before_filter :authenticate_user!

  # GET /grant_trainee_statuss
  # GET /grant_trainee_statuss.json
  def index
    # debugger
    @grant_trainee_statuss = GrantTraineeStatus.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @grant_trainee_statuss }
    end
  end

  # GET /grant_trainee_statuss.js
  def new
    # debugger
    @grant_trainee_status = GrantTraineeStatus.new
  end

  def create
    @grant_trainee_status = GrantTraineeStatus.new(params[:grant_trainee_status])
    @grant_trainee_status.save
    @grant_trainee_statuses = GrantTraineeStatus.all
  end

  def destroy
    @grant_trainee_status = GrantTraineeStatus.find(params[:id])
    @grant_trainee_status.destroy
  end
end
