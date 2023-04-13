# frozen_string_literal: true

class TraineeServicesController < ApplicationController
  before_action :authenticate_user!

  # GET /trainee_services/new
  # GET /trainee_services/new.json
  def new
    trainee = Trainee.find(params[:trainee_id])
    @trainee_service = trainee.trainee_services.build
    authorize @trainee_service
  end

  # POST /trainee_services
  # POST /trainee_services.json
  def create
    @trainee_service = TraineeService.new(trainee_service_params)
    authorize @trainee_service
    @trainee_service.save
    @trainee = @trainee_service.trainee
  end

  # GET /trainee_services/1/edit
  def edit
    @trainee_service = TraineeService.find(params[:id])
    authorize @trainee_service
  end

  # PUT /trainee_services/1
  # PUT /trainee_services/1.json
  def update
    @trainee_service = TraineeService.find(params[:id])
    authorize @trainee_service

    @trainee_service.update_attributes(trainee_service_params)
  end

  # DELETE /trainee_services/1
  # DELETE /trainee_services/1.json
  def destroy
    @trainee_service = TraineeService.find(params[:id])
    authorize @trainee_service

    @trainee_service.destroy
  end

  private

  def trainee_service_params
    ts_params = params.require(:trainee_service)
                      .permit(:name, :start_date, :end_date, :trainee_id)
    ts_params[:start_date] = opero_str_to_date(ts_params[:start_date])
    ts_params[:end_date] = opero_str_to_date(ts_params[:end_date])
    ts_params
  end
end
