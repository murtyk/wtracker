class SpecialServicesController < ApplicationController
  before_filter :authenticate_user!

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
    @special_service = SpecialService.new(params[:special_service])
    @special_service.save
    @special_services = SpecialService.all
  end

  def destroy
    @special_service = SpecialService.find(params[:id])
    @special_service.destroy if @special_service.applicants.empty?
  end
end
