# frozen_string_literal: true

# An employer belogs to an account and source
# REFACTOR: too many custom routes
# how about moving add_google_company and get_google_company
#    to a new resource? Say Google or Company?
# Also explore add another resource MapService
class EmployersController < ApplicationController
  before_action :authenticate_user!

  # ajax request job search analyze page
  def add_google_company
    @employer,
    @employer_exists,
    @error = EmployerFactory.create_from_job_search(current_user, params)
    @action_cell_id = ['#', params.permit![:action_cell_id]].join
    @add_company_id = ['#', params.permit![:add_company_id]].join
  end

  # ajax request job search analyze function. calls for each company
  def get_google_company
    name, location, _city_id = params[:name_location].split('::')
    company = Company.new(name, location, current_user)
    company.search
    render json: { found: company.found }
  end

  # for trainee interactions
  def list_for_trainee
    employers = EmployerServices.new(current_user, params)
                                .employers_for_trainee_interaction
    render json: employers
  end

  # ajax request from klass events for adding employers to an event
  # REFACTOR: No need for this route. We can leverage index.
  def search
    employers = EmployerServices.new(current_user, filter_params).search

    respond_to do |format|
      format.json { render json: employers }
    end
  end

  # for sending emails
  # REFACTOR: should be handled by contacts controller. Why here?
  def contacts_search
    contacts = EmployerServices.new(current_user, filter_params).search_contacts
    respond_to do |format|
      format.json { render json: contacts }
    end
  end

  def index
    @employers = EmployerServices.new(current_user, filter_params).search
    @employers_count = @employers.count

    return if request.format.xls?

    @employers = @employers.paginate(page: params.permit![:page], per_page: 20)
  end

  def mapview
    @employer_map = EmployersMap.new(current_user, filter_params)
  end

  def near_by_trainees
    @employer_map = EmployersMap.new(current_user, params.merge(near_by_trainees: true))
    @trainee_email = current_user
                     .trainee_emails
                     .new(trainee_ids: @employer_map.trainee_ids,
                          trainee_names: @employer_map.trainee_names,
                          klass_id: 0)
  end

  def analysis
    @analysis = employer_analysis
  end

  def address_location
    employer = current_user.employers.find(params[:id])
    # debugger
    render json: employer.location.to_json
  end

  def show
    @employer = Employer.find(params[:id]).decorate
    authorize @employer
  end

  def new
    @employer = Employer.new(employer_source_id: current_user.default_employer_source_id)
    logger.info { "[#{current_user.name}] [employer new]" }
    authorize @employer
    @employer.build_address
  end

  def edit
    @employer = Employer.find(params[:id])
    @employer.build_address unless @employer.address
    authorize @employer
  end

  def create
    authorize Employer.new

    @employer, saved = EmployerFactory.create_employer(current_user, employer_params)

    respond_to do |format|
      if saved
        notice = 'Employer was successfully created.'
        format.html { redirect_to @employer, notice: notice }
      else
        format.html { render :new }
      end
      format.js
    end
  end

  def update
    authorize Employer.find(params[:id])

    saved,
    @employer,
    error_message = EmployerFactory.update_employer(params[:id],
                                                    employer_params)

    if saved
      notice = 'Employer was successfully updated.'
      redirect_to @employer, notice: notice
    else
      flash[:error] = error_message
      render :edit
    end
  end

  def destroy
    @employer = Employer.find(params[:id])
    authorize @employer

    @employer.destroy
  end

  private

  def employer_params
    params.require(:employer)
          .permit(:name, :phone_no, :website, :trainee_ids, :employer_source_id,
                  sector_ids: [],
                  address_attributes: %i[id line1 line2 city state zip])
  end

  def filter_params
    params.permit![:filters]
  end
end
