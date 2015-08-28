# this setting is available for grants where applicants can apply
# an applicant might be accepted or declined based on employment status
class EmploymentStatusesController < ApplicationController
  before_filter :authenticate_user!

  # GET /employment_statuses
  # GET /employment_statuses.json
  def index
    # debugger
    @employment_statuses = EmploymentStatus.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @employment_statuses }
    end
  end

  # GET /employment_statuses.js
  def new
    # debugger
    @employment_status = EmploymentStatus.new
    authorize @employment_status
  end

  def create
    @employment_status = EmploymentStatus.new(employment_status_params)
    authorize @employment_status
    if @employment_status.save
      redirect_to(@employment_status,
                  notice: 'Employment Status was successfully created.')
    else
      render :new
    end
  end

  def show
    @employment_status = EmploymentStatus.find(params[:id])
    authorize @employment_status
  end

  def edit
    @employment_status = EmploymentStatus.find(params[:id])
    authorize @employment_status
  end

  def update
    @employment_status = EmploymentStatus.find(params[:id])
    authorize @employment_status
    if @employment_status.update_attributes(employment_status_params)
      redirect_to(@employment_status,
                  notice: 'Employment Status was successfully updated.')
    else
      render :edit
    end
  end

  def destroy
    @employment_status = EmploymentStatus.find(params[:id])
    authorize @employment_status
    @employment_status.destroy
    respond_to do |format|
      format.html { redirect_to employment_statuses_url }
      format.js
      format.json { head :no_content }
    end
  end

  private

  def employment_status_params
    params.require(:employment_status)
      .permit(:status, :action, :email_subject, :email_body)
  end
end
