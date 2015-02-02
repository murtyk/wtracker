class EmployerSectorsController < ApplicationController
  before_filter :authenticate_user!

  # GET /employer_sectors/new
  # GET /employer_sectors/new.json
  def new
    employer = Employer.find(params[:employer_id])

    @employer_sector = employer.employer_sectors.build
    # authorize @employer_sector
    authorize EmployerSector

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @employer_sector }
    end
  end

  # POST /employer_sectors
  # POST /employer_sectors.json
  def create
    @employer = Employer.find(params[:employer_sector][:employer_id])
    @employer_sector = @employer.employer_sectors
                                .new(sector_id: params[:employer_sector][:sector_id])
    authorize @employer_sector

    @employer_sector.save
  end

  # DELETE /employer_sectors/1
  # DELETE /employer_sectors/1.json
  def destroy
    @employer_sector = EmployerSector.find(params[:id])
    authorize @employer_sector

    @employer_sector.destroy

    respond_to do |format|
      format.html { redirect_to employer_sectors_url }
      format.js
      format.json { head :no_content }
    end
  end
end
