# frozen_string_literal: true

class SpecialServicesController < ApplicationController
  before_action :authenticate_user!

  # GET /special_services
  # GET /special_services.json
  def index
    # debugger
    @special_services = SpecialService.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @special_services }
    end
  end

  # GET /special_services.js
  def new
    # debugger
    @special_service = SpecialService.new
  end

  def create
    @special_service = SpecialService.new(special_service_params)
    @special_service.save
    @special_services = SpecialService.all
  end

  def destroy
    @special_service = SpecialService.find(params[:id])
    @special_service.destroy if @special_service.applicants.empty?
  end

  private

  def special_service_params
    params.require(:special_service).permit(:name)
  end
end
