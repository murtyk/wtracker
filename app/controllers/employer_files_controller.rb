class EmployerFilesController < ApplicationController
  before_action :authenticate_user!

  # GET /employer_files/1
  # GET /employer_files/1.json
  def show
    @employer_file = EmployerFile.find(params[:id])
    url = Amazon.file_url @employer_file.file
    redirect_to url.to_s
  end

  # GET /employer_files/new
  # GET /employer_files/new.json
  def new
    employer = Employer.find(params[:employer_id])
    @employer_file = employer.employer_files.new
  end

  # POST /employer_files
  # POST /employer_files.json
  def create
    saved,
    _error_message,
    @employer_file = EmployerFactory.add_employer_file(employer_file_params,
                                                       current_user)
    respond_to do |format|
      if saved
        notice = 'file was successfully saved.'
        employer = @employer_file.employer
        format.html { redirect_to employer, notice: notice }
        format.js
      else
        format.html { render :new }
      end
    end
  end

  # DELETE /employer_files/1
  # DELETE /employer_files/1.json
  def destroy
    @employer_file = EmployerFile.find(params[:id])
    @employer_file.destroy

    respond_to do |format|
      format.html { redirect_to employer_files_url }
      format.js
      format.json { head :no_content }
    end
  end

  private

  def employer_file_params
    params.require(:employer_file).permit(:employer_id, :file, :notice)
  end
end
