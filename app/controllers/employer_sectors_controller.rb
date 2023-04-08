# frozen_string_literal: true

class EmployerSectorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employer, only: %i[new create]

  # GET /employer_sectors/new
  # GET /employer_sectors/new.json
  def new
    @employer_sector = @employer.employer_sectors.new
    authorize @employer_sector
    # authorize EmployerSector

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @employer_sector }
    end
  end

  # POST /employer_sectors
  # POST /employer_sectors.json
  def create
    @employer_sector = @employer.employer_sectors
                                .new(employer_sector_params)
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

  private

  def employer_sector_params
    params.require(:employer_sector).permit(:sector_id)
  end

  def set_employer
    e_id = params[:employer_id] || params[:employer_sector][:employer_id]
    @employer = Employer.find e_id
  end
end
