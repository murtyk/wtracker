class Admin
  # for opero admin to manage sectors (alias industries)
  class SectorsController < ApplicationController
    before_filter :authenticate_admin!

    # GET /sectors
    # GET /sectors.json
    def index
      @sectors = Sector.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @sectors }
      end
    end

    # GET /sectors/1
    # GET /sectors/1.json
    def show
      @sector = Sector.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @sector }
      end
    end

    # GET /sectors/new
    # GET /sectors/new.json
    def new
      @sector = Sector.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sector }
      end
    end

    # POST /sectors
    # POST /sectors.json
    def create
      @sector = Sector.new(sector_params)

      respond_to do |format|
        if @sector.save
          notice = 'Sector was successfully created.'
          format.html { redirect_to [:admin, @sector], notice: notice }
          format.json { render json: @sector, status: :created, location: @sector }
        else
          format.html { render :new }
          format.json { render json: @sector.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sector_params
      params.require(:sector)
        .permit(:name)
    end
  end
end
