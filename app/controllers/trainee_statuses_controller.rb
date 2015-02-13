class TraineeStatusesController < ApplicationController
  before_filter :authenticate_user!

  # GET /trainee_statuses/new
  # GET /trainee_statuses/new.json
  def new
    trainee = Trainee.find(params[:trainee_id])
    @trainee_status = trainee.trainee_statuses.build
    authorize @trainee_status
  end

  # GET /trainee_statuses/1/edit
  def edit
    @trainee_status = TraineeStatus.find(params[:id])
    authorize @trainee_status
  end

  # POST /trainee_statuses
  # POST /trainee_statuses.json
  def create
    @trainee_status = TraineeStatus.new(params[:trainee_status])
    authorize @trainee_status
    @trainee_status.save
    @trainee = @trainee_status.trainee
  end

  # PUT /trainee_statuses/1
  # PUT /trainee_statuses/1.json
  def update
    @trainee_status = TraineeStatus.find(params[:id])
    authorize @trainee_status

    @trainee_status.update_attributes(params[:trainee_status])
  end

  # DELETE /trainee_statuses/1
  # DELETE /trainee_statuses/1.json
  def destroy
    @trainee_status = TraineeStatus.find(params[:id])
    authorize @trainee_status

    @trainee_status.destroy
  end
end
