# An employer belogs to an account and source
# REFACTOR: too many custom routes
# how about moving add_google_company, get_google_company, search_google
#    to a new resource? Say Google or Company?
# Also explore add another resource MapService
class EmployersController < ApplicationController
  # before_filter :authenticate_user!, except: [:list_for_trainee]
  before_filter :user_and_no_trainee, except: [:list_for_trainee]
  before_action :user_or_trainee, only: [:list_for_trainee]

  # ajax request job search analyze page
  def add_google_company
    # debugger

    @employer,
    @employer_exists,
    @error = EmployerFactory.create_from_job_search(current_user, params)
    @action_cell_id = '#' + params[:action_cell_id]
    @add_company_id = '#' + params[:add_company_id]
  end

  # ajax request job search analyze function. calls for each company
  def get_google_company
    name, location, _city_id = params[:name_location].split('::')
    company = Company.new(name, location, current_user)
    company.search
    render json: { found: company.found }
  end

  # google search menu.
  def search_google
    @companies = CompanyFinder.google_search(params[:filters]) if params[:filters]
  end

  # for trainee interactions
  def list_for_trainee
    employers = EmployerServices.new(params).employers_for_trainee_interaction
    render json: employers
  end

  # ajax request from klass events for adding employers to an event
  def search
    employers = EmployerServices.new(params[:filters]).search

    respond_to do |format|
      format.json { render json: employers }
    end
  end

  # for sending emails
  def contacts_search
    contacts = EmployerServices.new(params[:filters]).search_contacts
    respond_to do |format|
      format.json { render json: contacts }
    end
  end

  def index
    @employers = EmployerServices.new(params[:filters]).search
    @employers_count = @employers.count
    return if request.format.xls?
    @employers = @employers.to_a.paginate(page: params[:page], per_page: 20)
  end

  def mapview
    @employer_map = EmployersMap.new(params[:filters])
  end

  def analysis
    @analysis = employer_analysis
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

    @employer, saved = EmployerFactory.create_employer(current_user, params[:employer])

    respond_to do |format|
      if saved
        notice = 'Employer was successfully created.'
        format.html { redirect_to @employer, notice: notice }
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  def update
    authorize Employer.find(params[:id])

    saved, @employer, error_message = EmployerFactory.update_employer(params)

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
end
