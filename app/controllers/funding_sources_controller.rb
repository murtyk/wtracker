class FundingSourcesController < ApplicationController
  before_filter :authenticate_user!

  # GET /funding_sources
  # GET /funding_sources.json
  def index
    # debugger
    @funding_sources = FundingSource.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @funding_sources }
    end
  end

  # GET /funding_sources.js
  def new
    # debugger
    @funding_source = FundingSource.new
    authorize @funding_source
  end

  def create
    @funding_source = FundingSource.new(params[:funding_source])
    authorize @funding_source
    @funding_source.save
    @funding_sources = FundingSource.all
  end

  def destroy
    @funding_source = FundingSource.find(params[:id])
    authorize @funding_source
    @funding_source.destroy if @funding_source.trainees.empty?
  end
end
